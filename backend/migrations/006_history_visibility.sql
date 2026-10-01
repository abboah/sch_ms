-- 006: two visibility gaps found by the API tests.

-- Parents can still see the classes their child has completed (old report cards, closed terms).
-- Previously only *active* enrolments counted, so last year's section and its grades vanished
-- from the parent's view the moment the term closed.
create or replace function app.child_in_section(sec uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from enrollments e
                 join guardian_student gs on gs.student_id = e.student_id
                 where e.class_section_id = sec and e.status in ('active', 'completed')
                   and gs.guardian_id = app.person_id())
$$;

-- A teacher sees every teacher row of the sections they teach (the class page lists co-teachers),
-- not only their own row.
create policy st_teacher_section on section_teachers for select to app_user
  using (app.teaches_section(section_id));
