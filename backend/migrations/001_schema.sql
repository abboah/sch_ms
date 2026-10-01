-- Homeroom schema. Every tenant-owned row carries school_id, and cross-table
-- foreign keys are composite (id, school_id) so a row can never point at another
-- school's data, even if an RLS policy has a gap.

do $$ begin
  if not exists (select 1 from pg_roles where rolname = 'app_user') then
    create role app_user nologin;   -- on Supabase, map this to `authenticated`
  end if;
end $$;

create schema if not exists app;

create type person_role       as enum ('admin', 'teacher', 'guardian', 'student');
create type enrollment_status as enum ('active', 'completed', 'withdrawn');
create type attendance_status as enum ('present', 'late', 'absent', 'excused');
create type invoice_status    as enum ('unpaid', 'partial', 'paid', 'void');
create type payment_status    as enum ('pending', 'succeeded', 'failed');
create type payment_method    as enum ('card', 'mtn_momo', 'telecel_cash', 'manual');

create table schools (
  id       uuid primary key default gen_random_uuid(),
  name     text not null,
  timezone text not null default 'Africa/Accra'
);

create table terms (
  id        uuid primary key default gen_random_uuid(),
  school_id uuid not null references schools (id),
  name      text not null,
  starts_on date not null,
  ends_on   date not null,
  closed    boolean not null default false,   -- closed terms lock teacher writes
  check (ends_on > starts_on),
  unique (id, school_id)
);

create table people (
  id           uuid primary key default gen_random_uuid(),
  school_id    uuid not null references schools (id),
  full_name    text not null,
  role         person_role not null,
  contact      jsonb not null default '{}',
  auth_user_id uuid unique,
  created_at   timestamptz not null default now(),
  unique (id, school_id)
);

create table guardian_student (
  school_id          uuid not null,
  guardian_id        uuid not null,
  student_id         uuid not null,
  relationship       text not null default 'guardian',
  is_primary_contact boolean not null default false,
  primary key (guardian_id, student_id),
  foreign key (guardian_id, school_id) references people (id, school_id),
  foreign key (student_id,  school_id) references people (id, school_id)
);

create table class_sections (
  id                  uuid primary key default gen_random_uuid(),
  school_id           uuid not null references schools (id),
  term_id             uuid not null,
  name                text not null,
  grade_level         text not null,
  homeroom_teacher_id uuid,
  unique (id, school_id),
  foreign key (term_id, school_id) references terms (id, school_id),
  foreign key (homeroom_teacher_id, school_id) references people (id, school_id)
);

-- Who teaches what. Homeroom teachers are added automatically (trigger below).
create table section_teachers (
  school_id  uuid not null,
  section_id uuid not null,
  teacher_id uuid not null,
  subject    text not null,
  primary key (section_id, teacher_id, subject),
  foreign key (section_id, school_id) references class_sections (id, school_id),
  foreign key (teacher_id, school_id) references people (id, school_id)
);

create table enrollments (
  id               uuid primary key default gen_random_uuid(),
  school_id        uuid not null,
  student_id       uuid not null,
  class_section_id uuid not null,
  status           enrollment_status not null default 'active',  -- soft delete = status change
  unique (student_id, class_section_id),
  foreign key (student_id,       school_id) references people (id, school_id),
  foreign key (class_section_id, school_id) references class_sections (id, school_id)
);

create table periods (
  id               uuid primary key default gen_random_uuid(),
  school_id        uuid not null,
  class_section_id uuid not null,
  teacher_id       uuid not null,
  subject          text not null,
  weekday          smallint not null check (weekday between 1 and 7),  -- ISO, 1 = Monday
  starts_at        time not null,
  ends_at          time not null,
  check (ends_at > starts_at),
  unique (id, school_id),
  foreign key (class_section_id, school_id) references class_sections (id, school_id),
  foreign key (teacher_id,       school_id) references people (id, school_id)
);

create table attendance_records (
  id               uuid primary key default gen_random_uuid(),
  school_id        uuid not null,
  student_id       uuid not null,
  class_section_id uuid not null,
  period_id        uuid,
  period_date      date not null,
  status           attendance_status not null,
  marked_by        uuid not null,
  note             text,
  marked_at        timestamptz not null default now(),
  unique nulls not distinct (student_id, class_section_id, period_id, period_date),
  foreign key (student_id,       school_id) references people (id, school_id),
  foreign key (class_section_id, school_id) references class_sections (id, school_id),
  foreign key (marked_by,        school_id) references people (id, school_id),
  foreign key (period_id,        school_id) references periods (id, school_id)
);

create table assessments (
  id               uuid primary key default gen_random_uuid(),
  school_id        uuid not null,
  class_section_id uuid not null,
  subject          text not null,
  title            text not null,
  weight           numeric(5,2) not null check (weight > 0 and weight <= 100),
  max_score        numeric(6,2) not null check (max_score > 0),
  due_date         date,
  unique (id, school_id),
  foreign key (class_section_id, school_id) references class_sections (id, school_id)
);

create table grades (
  id            uuid primary key default gen_random_uuid(),
  school_id     uuid not null,
  assessment_id uuid not null,
  student_id    uuid not null,
  score         numeric(6,2) check (score is null or score >= 0),
  comment       text,
  updated_at    timestamptz not null default now(),
  unique (assessment_id, student_id),
  foreign key (assessment_id, school_id) references assessments (id, school_id),
  foreign key (student_id,    school_id) references people (id, school_id)
);

create table invoices (
  id          uuid primary key default gen_random_uuid(),
  school_id   uuid not null,
  student_id  uuid not null,
  term_id     uuid not null,
  description text not null,
  amount_due  numeric(12,2) not null check (amount_due >= 0),
  status      invoice_status not null default 'unpaid',  -- "overdue" is derived from due_date
  due_date    date not null,
  unique (id, school_id),
  foreign key (student_id, school_id) references people (id, school_id),
  foreign key (term_id,    school_id) references terms (id, school_id)
);

create table payments (
  id           uuid primary key default gen_random_uuid(),
  school_id    uuid not null,
  invoice_id   uuid not null,
  provider_ref text not null unique,      -- idempotency key from the gateway
  amount       numeric(12,2) not null check (amount > 0),
  method       payment_method not null,
  status       payment_status not null default 'pending',
  paid_at      timestamptz,
  created_at   timestamptz not null default now(),
  foreign key (invoice_id, school_id) references invoices (id, school_id)
);

create table message_threads (
  id          uuid primary key default gen_random_uuid(),
  school_id   uuid not null,
  student_id  uuid not null,     -- a thread is always about one child
  teacher_id  uuid not null,
  guardian_id uuid not null,
  created_at  timestamptz not null default now(),
  unique (id, school_id),
  unique (student_id, teacher_id, guardian_id),
  foreign key (student_id,  school_id) references people (id, school_id),
  foreign key (teacher_id,  school_id) references people (id, school_id),
  foreign key (guardian_id, school_id) references people (id, school_id)
);

create table messages (
  id         uuid primary key default gen_random_uuid(),
  school_id  uuid not null,
  thread_id  uuid not null,
  sender_id  uuid not null,
  body       text not null check (length(body) > 0),
  created_at timestamptz not null default now(),
  foreign key (thread_id, school_id) references message_threads (id, school_id),
  foreign key (sender_id, school_id) references people (id, school_id)
);

create table announcements (
  id                uuid primary key default gen_random_uuid(),
  school_id         uuid not null,
  author_id         uuid not null,
  class_section_id  uuid,                  -- null = school-wide
  title             text not null,
  body              text not null,
  requires_response boolean not null default false,  -- permission slips
  published_at      timestamptz,           -- null = draft
  unique (id, school_id),
  foreign key (author_id,        school_id) references people (id, school_id),
  foreign key (class_section_id, school_id) references class_sections (id, school_id)
);

create table announcement_responses (
  school_id       uuid not null,
  announcement_id uuid not null,
  student_id      uuid not null,
  guardian_id     uuid not null,
  response        text not null check (response in ('yes', 'no')),
  responded_at    timestamptz not null default now(),
  primary key (announcement_id, student_id),
  foreign key (announcement_id, school_id) references announcements (id, school_id),
  foreign key (student_id,      school_id) references people (id, school_id),
  foreign key (guardian_id,     school_id) references people (id, school_id)
);

create table homework (
  id               uuid primary key default gen_random_uuid(),
  school_id        uuid not null,
  class_section_id uuid not null,
  title            text not null,
  body             text,
  due_date         date not null,
  posted_by        uuid not null,
  created_at       timestamptz not null default now(),
  foreign key (class_section_id, school_id) references class_sections (id, school_id),
  foreign key (posted_by,        school_id) references people (id, school_id)
);

create table conference_slots (
  id                     uuid primary key default gen_random_uuid(),
  school_id              uuid not null,
  teacher_id             uuid not null,
  starts_at              timestamptz not null,
  ends_at                timestamptz not null,
  booked_by_guardian_id  uuid,
  student_id             uuid,
  check (ends_at > starts_at),
  unique (teacher_id, starts_at),
  foreign key (teacher_id,            school_id) references people (id, school_id),
  foreign key (booked_by_guardian_id, school_id) references people (id, school_id),
  foreign key (student_id,            school_id) references people (id, school_id)
);

create table push_tokens (
  id         uuid primary key default gen_random_uuid(),
  person_id  uuid not null references people (id),
  token      text not null unique,
  platform   text not null check (platform in ('ios', 'android', 'web')),
  created_at timestamptz not null default now()
);

create table notification_prefs (
  person_id uuid primary key references people (id),
  push      boolean not null default true,
  email     boolean not null default true,
  sms       boolean not null default true
);

create table audit_log (
  id         bigint generated always as identity primary key,
  school_id  uuid not null,
  actor_id   uuid not null,
  action     text not null,
  table_name text not null,
  row_id     uuid,
  student_id uuid,
  at         timestamptz not null default now()
);

create index on enrollments (student_id);
create index on enrollments (class_section_id);
create index on attendance_records (student_id, period_date);
create index on attendance_records (class_section_id, period_date);
create index on grades (student_id);
create index on invoices (student_id);
create index on payments (invoice_id);
create index on messages (thread_id, created_at);
create index on guardian_student (student_id);
create index on audit_log (student_id, at);

-- Homeroom teachers are always teachers of their section.
create function sync_homeroom() returns trigger language plpgsql security definer
set search_path = public as $$
begin
  if new.homeroom_teacher_id is not null then
    insert into section_teachers (school_id, section_id, teacher_id, subject)
    values (new.school_id, new.id, new.homeroom_teacher_id, 'Homeroom')
    on conflict do nothing;
  end if;
  return new;
end $$;

create trigger class_sections_sync_homeroom
after insert or update of homeroom_teacher_id on class_sections
for each row execute function sync_homeroom();
