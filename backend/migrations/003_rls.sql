-- Row-level security. Each policy maps to a cell of the permissions matrix
-- (spec section 07). Deny by default: a table/operation with no policy is closed,
-- including DELETE on anything that must be soft-deleted.

do $$
declare t text;
begin
  foreach t in array array[
    'schools','terms','people','guardian_student','class_sections','section_teachers',
    'enrollments','periods','attendance_records','assessments','grades','invoices',
    'payments','message_threads','messages','announcements','announcement_responses',
    'homework','conference_slots','push_tokens','notification_prefs','audit_log'
  ] loop
    execute format('alter table %I enable row level security', t);
  end loop;
end $$;

-- ---- Admin ---------------------------------------------------------------
do $$
declare t text;
  scope text := 'app.is_admin() and school_id = app.school_id()';
begin
  -- read + create + update, never delete (history stays for transcripts)
  foreach t in array array['people','enrollments','attendance_records','invoices','payments'] loop
    execute format('create policy admin_select on %I for select to app_user using (%s)', t, scope);
    execute format('create policy admin_insert on %I for insert to app_user with check (%s)', t, scope);
    execute format('create policy admin_update on %I for update to app_user using (%s) with check (%s)', t, scope, scope);
  end loop;
  -- full control of school configuration
  foreach t in array array['terms','class_sections','section_teachers','periods',
                           'guardian_student','announcements','conference_slots'] loop
    execute format('create policy admin_all on %I for all to app_user using (%s) with check (%s)', t, scope, scope);
  end loop;
  -- view only (teachers own grades/homework/messages; admin audits)
  foreach t in array array['assessments','grades','homework','message_threads','messages',
                           'audit_log','announcement_responses'] loop
    execute format('create policy admin_select on %I for select to app_user using (%s)', t, scope);
  end loop;
end $$;

-- ---- schools -------------------------------------------------------------
create policy schools_own on schools for select to app_user using (id = app.school_id());

-- ---- terms ---------------------------------------------------------------
create policy terms_read on terms for select to app_user using (school_id = app.school_id());

-- ---- people --------------------------------------------------------------
create policy people_self on people for select to app_user using (id = app.person_id());

create policy people_teacher on people for select to app_user using (
  app.role() = 'teacher' and (
    (role = 'student'  and app.teaches_student(id)) or
    (role = 'guardian' and app.teaches_a_child_of(id))));

create policy people_guardian on people for select to app_user using (
  app.role() = 'guardian' and (
    (role = 'student' and app.guardian_of(id)) or
    (role = 'teacher' and app.teacher_of_my_child(id))));

-- ---- guardian_student ----------------------------------------------------
create policy gs_guardian on guardian_student for select to app_user
  using (guardian_id = app.person_id());
create policy gs_teacher on guardian_student for select to app_user
  using (app.role() = 'teacher' and app.teaches_student(student_id));

-- ---- class structure -----------------------------------------------------
create policy sections_teacher  on class_sections for select to app_user using (app.teaches_section(id));
create policy sections_guardian on class_sections for select to app_user using (app.child_in_section(id));

create policy st_teacher  on section_teachers for select to app_user using (teacher_id = app.person_id());
create policy st_guardian on section_teachers for select to app_user using (app.child_in_section(section_id));

create policy enr_teacher  on enrollments for select to app_user using (app.teaches_section(class_section_id));
create policy enr_guardian on enrollments for select to app_user using (app.guardian_of(student_id));

create policy periods_teacher  on periods for select to app_user using (app.teaches_section(class_section_id));
create policy periods_guardian on periods for select to app_user using (app.child_in_section(class_section_id));

-- ---- attendance ----------------------------------------------------------
create policy att_teacher_select on attendance_records for select to app_user
  using (app.role() = 'teacher' and app.teaches_section(class_section_id));
create policy att_teacher_insert on attendance_records for insert to app_user
  with check (school_id = app.school_id() and marked_by = app.person_id()
              and app.can_mark(class_section_id, student_id));
create policy att_teacher_update on attendance_records for update to app_user
  using (app.role() = 'teacher' and app.teaches_section(class_section_id) and app.section_open(class_section_id))
  with check (school_id = app.school_id() and marked_by = app.person_id()
              and app.can_mark(class_section_id, student_id));
create policy att_guardian on attendance_records for select to app_user
  using (app.guardian_of(student_id));

-- ---- assessments & grades ------------------------------------------------
create policy assess_teacher_select on assessments for select to app_user
  using (app.role() = 'teacher' and app.teaches_section(class_section_id));
create policy assess_teacher_insert on assessments for insert to app_user
  with check (school_id = app.school_id() and app.role() = 'teacher'
              and app.teaches_section(class_section_id) and app.section_open(class_section_id));
create policy assess_teacher_update on assessments for update to app_user
  using (app.role() = 'teacher' and app.teaches_section(class_section_id) and app.section_open(class_section_id))
  with check (school_id = app.school_id() and app.teaches_section(class_section_id));
create policy assess_guardian on assessments for select to app_user
  using (app.child_in_section(class_section_id));

create policy grades_teacher_select on grades for select to app_user
  using (app.role() = 'teacher' and app.teaches_assessment(assessment_id));
create policy grades_teacher_insert on grades for insert to app_user
  with check (school_id = app.school_id() and app.can_grade(assessment_id, student_id));
create policy grades_teacher_update on grades for update to app_user
  using (app.role() = 'teacher' and app.teaches_assessment(assessment_id))
  with check (school_id = app.school_id() and app.can_grade(assessment_id, student_id));
create policy grades_guardian on grades for select to app_user
  using (app.guardian_of(student_id));

-- ---- fees: admin + guardian only; guardians never write -------------------
create policy inv_guardian on invoices for select to app_user using (app.guardian_of(student_id));
create policy pay_guardian on payments for select to app_user using (app.guardian_of_invoice(invoice_id));

-- ---- messaging -----------------------------------------------------------
create policy thr_participant on message_threads for select to app_user
  using (teacher_id = app.person_id() or guardian_id = app.person_id());
create policy thr_teacher_insert on message_threads for insert to app_user
  with check (school_id = app.school_id() and app.role() = 'teacher' and teacher_id = app.person_id()
              and app.teaches_student(student_id) and app.guardian_of(guardian_id, student_id));
create policy thr_guardian_insert on message_threads for insert to app_user
  with check (school_id = app.school_id() and app.role() = 'guardian' and guardian_id = app.person_id()
              and app.guardian_of(student_id) and app.teacher_teaches(teacher_id, student_id));

create policy msg_participant on messages for select to app_user using (app.in_thread(thread_id));
create policy msg_send on messages for insert to app_user
  with check (school_id = app.school_id() and sender_id = app.person_id() and app.in_thread(thread_id));
-- messages are immutable: no update or delete policy

-- ---- announcements, responses, homework ----------------------------------
create policy ann_teacher_select on announcements for select to app_user
  using (app.role() = 'teacher' and school_id = app.school_id()
         and (published_at is not null or author_id = app.person_id())
         and (class_section_id is null or app.teaches_section(class_section_id)));
create policy ann_teacher_insert on announcements for insert to app_user
  with check (school_id = app.school_id() and app.role() = 'teacher' and author_id = app.person_id()
              and class_section_id is not null and app.teaches_section(class_section_id));
create policy ann_teacher_update on announcements for update to app_user
  using (author_id = app.person_id() and app.role() = 'teacher')
  with check (author_id = app.person_id() and class_section_id is not null
              and app.teaches_section(class_section_id));
create policy ann_guardian on announcements for select to app_user
  using (app.role() = 'guardian' and school_id = app.school_id() and published_at is not null
         and (class_section_id is null or app.child_in_section(class_section_id)));

create policy resp_guardian_select on announcement_responses for select to app_user
  using (guardian_id = app.person_id());
create policy resp_guardian_insert on announcement_responses for insert to app_user
  with check (school_id = app.school_id() and guardian_id = app.person_id()
              and app.guardian_of(student_id)
              and exists (select 1 from announcements a where a.id = announcement_id and a.requires_response));
create policy resp_guardian_update on announcement_responses for update to app_user
  using (guardian_id = app.person_id())
  with check (guardian_id = app.person_id() and app.guardian_of(student_id));

create policy hw_teacher_select on homework for select to app_user
  using (app.role() = 'teacher' and app.teaches_section(class_section_id));
create policy hw_teacher_insert on homework for insert to app_user
  with check (school_id = app.school_id() and posted_by = app.person_id() and app.role() = 'teacher'
              and app.teaches_section(class_section_id) and app.section_open(class_section_id));
create policy hw_teacher_update on homework for update to app_user
  using (posted_by = app.person_id() and app.role() = 'teacher')
  with check (posted_by = app.person_id() and app.teaches_section(class_section_id));
create policy hw_guardian on homework for select to app_user using (app.child_in_section(class_section_id));

-- ---- conferences ---------------------------------------------------------
create policy slot_teacher on conference_slots for all to app_user
  using (app.role() = 'teacher' and teacher_id = app.person_id())
  with check (school_id = app.school_id() and app.role() = 'teacher' and teacher_id = app.person_id());
create policy slot_guardian on conference_slots for select to app_user
  using (app.role() = 'guardian' and school_id = app.school_id()
         and (booked_by_guardian_id is null or booked_by_guardian_id = app.person_id())
         and app.teacher_of_my_child(teacher_id));
-- guardians book/release via book_conference_slot() / release_conference_slot()

-- ---- personal settings ---------------------------------------------------
create policy push_own on push_tokens for all to app_user
  using (person_id = app.person_id()) with check (person_id = app.person_id());
create policy prefs_own on notification_prefs for all to app_user
  using (person_id = app.person_id()) with check (person_id = app.person_id());

-- ---- grants --------------------------------------------------------------
-- Table privileges are broad on purpose; RLS above is the real gate. audit_log has
-- no insert policy: it is only written by app.log_read() and the service role.
grant usage on schema public, app to app_user;
grant select, insert, update, delete on all tables in schema public to app_user;
grant usage on all sequences in schema public to app_user;
grant execute on all functions in schema app to app_user;
grant execute on function student_summary(uuid), book_conference_slot(uuid, uuid),
  release_conference_slot(uuid) to app_user;
