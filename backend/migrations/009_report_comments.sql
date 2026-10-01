-- 009: report-card comments. One comment per (student, class_section, subject), written by the
-- teacher of that section while its term is open, same write gate as assessments/grades/homework
-- (app.section_open). Visible to guardians only once the term closes — comments are drafted and
-- refined over the term, not trickled out mid-draft the way live grades are; closing a term already
-- means "this term is done," so it doubles as "the report is issued" with no new state to invent.
-- Admin can always see them, for oversight before a term closes.

create table report_comments (
  id               uuid primary key default gen_random_uuid(),
  school_id        uuid not null,
  student_id       uuid not null,
  class_section_id uuid not null,
  subject          text not null,
  teacher_id       uuid not null,
  body             text not null,
  updated_at       timestamptz not null default now(),
  unique (id, school_id),
  unique (student_id, class_section_id, subject),
  foreign key (student_id, school_id) references people (id, school_id),
  foreign key (class_section_id, school_id) references class_sections (id, school_id),
  foreign key (teacher_id, school_id) references people (id, school_id)
);
create trigger report_comments_roles before insert or update on report_comments
  for each row execute function enforce_role('student_id', 'student', 'teacher_id', 'teacher');

alter table report_comments enable row level security;
create policy rc_teacher_select on report_comments for select to app_user
  using (app.role() = 'teacher' and app.teaches_section(class_section_id));
create policy rc_teacher_insert on report_comments for insert to app_user
  with check (school_id = app.school_id() and app.role() = 'teacher' and teacher_id = app.person_id()
              and app.teaches_section(class_section_id) and app.section_open(class_section_id));
create policy rc_teacher_update on report_comments for update to app_user
  using (app.role() = 'teacher' and app.teaches_section(class_section_id) and app.section_open(class_section_id))
  with check (school_id = app.school_id() and teacher_id = app.person_id() and app.teaches_section(class_section_id));
create policy rc_guardian_select on report_comments for select to app_user
  using (app.child_in_section(class_section_id) and not app.section_open(class_section_id));
create policy rc_admin_select on report_comments for select to app_user
  using (app.is_admin() and school_id = app.school_id());
grant select, insert, update on report_comments to app_user;
