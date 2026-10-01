-- 004: platform slice. From here on migrations are append-only feature slices
-- (tables + functions + policies + grants together).
--
-- Closes three gaps from the baseline:
--   * contact details leaked with the people row  -> person_contacts (own RLS)
--   * nothing checked that a "guardian" is a guardian -> enforce_role triggers
--   * score could exceed max_score -> check_grade_score trigger
-- and adds: accounts/sessions/OTP (service-only), idempotency keys (service-only),
-- the notification outbox + in-app inbox, thread read state.

-- ---------------------------------------------------------------------------
-- Contacts: phone/email move out of people so visibility is decided separately.
-- Admin and the person themself can see a contact; nobody else can, even a parent
-- who is allowed to see their child's teacher.
-- ---------------------------------------------------------------------------
create table person_contacts (
  person_id uuid primary key,
  school_id uuid not null,
  phone     text,
  email     text,
  foreign key (person_id, school_id) references people (id, school_id)
);
insert into person_contacts (person_id, school_id, phone, email)
select id, school_id, contact ->> 'phone', contact ->> 'email'
from people where contact <> '{}'::jsonb;
alter table people drop column contact;

alter table person_contacts enable row level security;
create policy contacts_admin_select on person_contacts for select to app_user
  using (app.is_admin() and school_id = app.school_id());
create policy contacts_admin_insert on person_contacts for insert to app_user
  with check (app.is_admin() and school_id = app.school_id());
create policy contacts_admin_update on person_contacts for update to app_user
  using (app.is_admin() and school_id = app.school_id())
  with check (app.is_admin() and school_id = app.school_id());
create policy contacts_self_select on person_contacts for select to app_user
  using (person_id = app.person_id());
create policy contacts_self_insert on person_contacts for insert to app_user
  with check (person_id = app.person_id() and school_id = app.school_id());
create policy contacts_self_update on person_contacts for update to app_user
  using (person_id = app.person_id())
  with check (person_id = app.person_id() and school_id = app.school_id());
grant select, insert, update on person_contacts to app_user;

-- ---------------------------------------------------------------------------
-- Role typing: the composite foreign keys stop cross-school references; this stops
-- cross-role ones (a teacher linked as a guardian, a guardian enrolled as a student).
-- Arguments come in (column, expected role) pairs.
-- ---------------------------------------------------------------------------
create function enforce_role() returns trigger language plpgsql security definer
set search_path = public as $$
declare
  i   int := 0;
  v   uuid;
  got person_role;
begin
  while i < tg_nargs loop
    execute format('select ($1).%I', tg_argv[i]) into v using new;
    if v is not null then
      select role into got from people where id = v;
      if got is distinct from tg_argv[i + 1]::person_role then
        raise exception '% must reference a % (found %)', tg_argv[i], tg_argv[i + 1],
          coalesce(got::text, 'no such person') using errcode = '23514';
      end if;
    end if;
    i := i + 2;
  end loop;
  return new;
end $$;

create trigger guardian_student_roles before insert or update on guardian_student
  for each row execute function enforce_role('guardian_id', 'guardian', 'student_id', 'student');
create trigger enrollments_roles before insert or update on enrollments
  for each row execute function enforce_role('student_id', 'student');
create trigger section_teachers_roles before insert or update on section_teachers
  for each row execute function enforce_role('teacher_id', 'teacher');
create trigger class_sections_roles before insert or update on class_sections
  for each row execute function enforce_role('homeroom_teacher_id', 'teacher');
create trigger periods_roles before insert or update on periods
  for each row execute function enforce_role('teacher_id', 'teacher');
create trigger attendance_roles before insert or update on attendance_records
  for each row execute function enforce_role('student_id', 'student');
create trigger grades_roles before insert or update on grades
  for each row execute function enforce_role('student_id', 'student');
create trigger invoices_roles before insert or update on invoices
  for each row execute function enforce_role('student_id', 'student');
create trigger threads_roles before insert or update on message_threads
  for each row execute function enforce_role('student_id', 'student', 'teacher_id', 'teacher', 'guardian_id', 'guardian');
create trigger slots_roles before insert or update on conference_slots
  for each row execute function enforce_role('teacher_id', 'teacher', 'booked_by_guardian_id', 'guardian', 'student_id', 'student');
create trigger responses_roles before insert or update on announcement_responses
  for each row execute function enforce_role('student_id', 'student', 'guardian_id', 'guardian');

create function check_grade_score() returns trigger language plpgsql security definer
set search_path = public as $$
declare v_max numeric;
begin
  if new.score is not null then
    select max_score into v_max from assessments where id = new.assessment_id;
    if new.score > v_max then
      raise exception 'score % exceeds the maximum of %', new.score, v_max using errcode = '23514';
    end if;
  end if;
  return new;
end $$;
create trigger grades_score_bound before insert or update of score, assessment_id on grades
  for each row execute function check_grade_score();

-- ---------------------------------------------------------------------------
-- Accounts and sessions. SERVICE ONLY: no grants to app_user, so a signed-in
-- user cannot read hashes or tokens even through a bug in the API.
-- One account can hold several people (an admin who is also a parent).
-- ---------------------------------------------------------------------------
create table accounts (
  id            uuid primary key default gen_random_uuid(),
  email         text unique check (email = lower(email)),
  phone         text unique,
  password_hash text,
  disabled_at   timestamptz,
  created_at    timestamptz not null default now(),
  check (email is not null or phone is not null)
);

alter table people drop constraint people_auth_user_id_key;
alter table people add constraint people_account_fk foreign key (auth_user_id) references accounts (id);
create index on people (auth_user_id);

create table refresh_tokens (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null,                 -- reuse of a rotated token revokes the family
  account_id  uuid not null references accounts (id),
  person_id   uuid not null references people (id),
  token_hash  text not null unique,
  expires_at  timestamptz not null,
  revoked_at  timestamptz,
  created_at  timestamptz not null default now()
);
create index on refresh_tokens (family_id);
create index on refresh_tokens (person_id);

create table otp_codes (
  id          uuid primary key default gen_random_uuid(),
  phone       text not null,
  code_hash   text not null,
  expires_at  timestamptz not null,
  attempts    int not null default 0,
  consumed_at timestamptz,
  created_at  timestamptz not null default now()
);
create index on otp_codes (phone, created_at);

create table idempotency_keys (
  person_id    uuid not null,
  key          text not null,
  request_hash text not null,
  status       int not null,
  body         jsonb,
  created_at   timestamptz not null default now(),
  primary key (person_id, key)
);

-- ---------------------------------------------------------------------------
-- Notifications: transactional outbox -> in-app inbox -> channel deliveries.
-- Triggers enqueue in the same transaction as the change. The worker (service
-- role) resolves recipients and channels. Nothing here is writable by app_user
-- except marking one's own inbox rows read.
-- ---------------------------------------------------------------------------
create table notification_outbox (
  id           bigint generated always as identity primary key,
  school_id    uuid not null,
  kind         text not null,
  ref_id       uuid,
  student_id   uuid,
  payload      jsonb not null default '{}',
  status       text not null default 'pending' check (status in ('pending', 'done', 'failed')),
  attempts     int not null default 0,
  run_after    timestamptz not null default now(),
  last_error   text,
  created_at   timestamptz not null default now(),
  processed_at timestamptz
);
create index on notification_outbox (status, run_after);

create table notifications (
  id         uuid primary key default gen_random_uuid(),
  school_id  uuid not null references schools (id),
  person_id  uuid not null references people (id),
  kind       text not null,
  title      text not null,
  body       text not null,
  data       jsonb not null default '{}',
  read_at    timestamptz,
  created_at timestamptz not null default now()
);
create index on notifications (person_id, created_at desc);

create table notification_deliveries (
  id              bigint generated always as identity primary key,
  notification_id uuid not null references notifications (id),
  channel         text not null check (channel in ('push', 'sms', 'email')),
  status          text not null check (status in ('sent', 'failed', 'skipped')),
  detail          text,
  at              timestamptz not null default now()
);
create index on notification_deliveries (notification_id);

alter table notifications enable row level security;
create policy notifications_own_select on notifications for select to app_user
  using (person_id = app.person_id());
create policy notifications_own_update on notifications for update to app_user
  using (person_id = app.person_id()) with check (person_id = app.person_id());
grant select, update (read_at) on notifications to app_user;

create function app.enqueue(p_kind text, p_school uuid, p_ref uuid, p_student uuid, p_payload jsonb default '{}')
returns void language sql security definer set search_path = public as $$
  insert into notification_outbox (school_id, kind, ref_id, student_id, payload)
  values (p_school, p_kind, p_ref, p_student, p_payload)
$$;

create function trg_attendance_notify() returns trigger language plpgsql security definer
set search_path = public as $$
begin
  if new.status in ('absent', 'late')
     and (tg_op = 'INSERT' or old.status is distinct from new.status) then
    perform app.enqueue('attendance.marked', new.school_id, new.id, new.student_id,
                        jsonb_build_object('status', new.status, 'date', new.period_date));
  end if;
  return new;
end $$;
create trigger attendance_notify after insert or update of status on attendance_records
  for each row execute function trg_attendance_notify();

create function trg_homework_notify() returns trigger language plpgsql security definer
set search_path = public as $$
begin
  perform app.enqueue('homework.posted', new.school_id, new.id, null,
                      jsonb_build_object('class_section_id', new.class_section_id, 'title', new.title,
                                         'due_date', new.due_date));
  return new;
end $$;
create trigger homework_notify after insert on homework
  for each row execute function trg_homework_notify();

create function trg_announcement_notify() returns trigger language plpgsql security definer
set search_path = public as $$
begin
  if new.published_at is not null and (tg_op = 'INSERT' or old.published_at is null) then
    perform app.enqueue('announcement.published', new.school_id, new.id, null,
                        jsonb_build_object('class_section_id', new.class_section_id, 'title', new.title));
  end if;
  return new;
end $$;
create trigger announcement_notify after insert or update of published_at on announcements
  for each row execute function trg_announcement_notify();

create function trg_message_notify() returns trigger language plpgsql security definer
set search_path = public as $$
declare v_student uuid;
begin
  select student_id into v_student from message_threads where id = new.thread_id;
  perform app.enqueue('message.sent', new.school_id, new.id, v_student,
                      jsonb_build_object('thread_id', new.thread_id, 'sender_id', new.sender_id));
  return new;
end $$;
create trigger message_notify after insert on messages
  for each row execute function trg_message_notify();

-- Only the trigger functions (SECURITY DEFINER) may enqueue; app users cannot forge events.
revoke execute on function app.enqueue(text, uuid, uuid, uuid, jsonb) from public;

-- Payments are inserted by the service role, so this fires for the webhook path.
create function trg_payment_notify() returns trigger language plpgsql security definer
set search_path = public as $$
declare v_student uuid;
begin
  if new.status = 'succeeded' and (tg_op = 'INSERT' or old.status is distinct from new.status) then
    select student_id into v_student from invoices where id = new.invoice_id;
    perform app.enqueue('payment.succeeded', new.school_id, new.id, v_student,
                        jsonb_build_object('invoice_id', new.invoice_id, 'amount', new.amount));
  end if;
  return new;
end $$;
create trigger payment_notify after insert or update of status on payments
  for each row execute function trg_payment_notify();

-- ---------------------------------------------------------------------------
-- Thread read state, for unread badges.
-- ---------------------------------------------------------------------------
create table thread_reads (
  thread_id    uuid not null references message_threads (id),
  person_id    uuid not null references people (id),
  last_read_at timestamptz not null default now(),
  primary key (thread_id, person_id)
);
alter table thread_reads enable row level security;
create policy thread_reads_own on thread_reads for all to app_user
  using (person_id = app.person_id())
  with check (person_id = app.person_id() and app.in_thread(thread_id));
grant select, insert, update on thread_reads to app_user;
