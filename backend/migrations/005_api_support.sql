-- 005: things the API needs that the baseline could not anticipate.

-- ---------------------------------------------------------------------------
-- Teachers can see colleagues who share a section with them (class pages list
-- every teacher of the section). Still no access to other teachers' contacts,
-- which live in person_contacts under their own policy.
-- ---------------------------------------------------------------------------
create function app.shares_section_with(t uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from section_teachers a
                 join section_teachers b on b.section_id = a.section_id
                 where a.teacher_id = app.person_id() and b.teacher_id = t)
$$;
create policy people_colleagues on people for select to app_user
  using (app.role() = 'teacher' and role = 'teacher' and app.shares_section_with(id));

-- ---------------------------------------------------------------------------
-- Announcements need a creation time to sort drafts.
-- ---------------------------------------------------------------------------
alter table announcements add column created_at timestamptz not null default now();
create index on announcements (school_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Permission slips: either guardian of a child may reply (and change the other's reply).
-- The baseline only let the original guardian update.
-- ---------------------------------------------------------------------------
drop policy resp_guardian_select on announcement_responses;
drop policy resp_guardian_update on announcement_responses;
create policy resp_guardian_select on announcement_responses for select to app_user
  using (app.guardian_of(student_id));
create policy resp_guardian_update on announcement_responses for update to app_user
  using (app.guardian_of(student_id))
  with check (guardian_id = app.person_id() and app.guardian_of(student_id));

-- ---------------------------------------------------------------------------
-- Every payment webhook we receive, valid or not, for debugging and reconciliation.
-- SERVICE ONLY.
-- ---------------------------------------------------------------------------
create table webhook_events (
  id           bigint generated always as identity primary key,
  provider     text not null,
  received_at  timestamptz not null default now(),
  outcome      text not null check (outcome in ('processed', 'ignored', 'unmatched', 'invalid_signature', 'error')),
  provider_ref text,
  invoice_id   uuid,
  body_sha256  text not null,
  detail       text
);
create index on webhook_events (received_at desc);
create index on webhook_events (provider_ref);

-- ---------------------------------------------------------------------------
-- Password reset / invitation links. SERVICE ONLY. Only the hash is stored.
-- ---------------------------------------------------------------------------
create table password_resets (
  id         uuid primary key default gen_random_uuid(),
  account_id uuid not null references accounts (id),
  token_hash text not null unique,
  expires_at timestamptz not null,
  used_at    timestamptz,
  created_at timestamptz not null default now()
);
create index on password_resets (account_id);

-- ---------------------------------------------------------------------------
-- Booking: distinguish "not yours / not available" (403-ish) from "already booked" (409).
-- SQLSTATE HR409 is ours; the API maps it to 409.
-- ---------------------------------------------------------------------------
create or replace function book_conference_slot(p_slot uuid, p_student uuid) returns void
language plpgsql security definer set search_path = public as $$
declare v_teacher uuid; v_booked uuid;
begin
  if app.role() <> 'guardian' or not app.guardian_of(p_student) then
    raise exception 'not permitted' using errcode = '42501';
  end if;
  select teacher_id, booked_by_guardian_id into v_teacher, v_booked
    from conference_slots where id = p_slot and school_id = app.school_id();
  if v_teacher is null or not app.teacher_teaches(v_teacher, p_student) then
    raise exception 'slot unavailable' using errcode = '42501';
  end if;
  if v_booked is not null then
    raise exception 'slot already booked' using errcode = 'HR409';
  end if;
  update conference_slots
     set booked_by_guardian_id = app.person_id(), student_id = p_student
   where id = p_slot and booked_by_guardian_id is null;
  if not found then
    raise exception 'slot already booked' using errcode = 'HR409';
  end if;
end $$;
