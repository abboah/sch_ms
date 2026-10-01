-- 008: two school-configurable entities, so different schools can run different
-- grading scales and fee catalogs on the same platform.
--
--   * grade_bands: a school's letter/band scheme (e.g. A 80-100). Read by anyone in
--     the school (report cards, gradebook), written by admin only. Purely additive:
--     a school with no bands configured sees exactly what it sees today.
--   * fee_items: a school's reusable named charges (e.g. "Term 1 Tuition"). Admin
--     only, both ways: invoices still carry their own description/amount, fee_item_id
--     is a convenience + reporting tag, not a new source of truth.

create table grade_bands (
  id        uuid primary key default gen_random_uuid(),
  school_id uuid not null references schools (id),
  label     text not null,
  min_score numeric(5,2) not null,
  max_score numeric(5,2) not null,
  check (min_score <= max_score),
  unique (id, school_id)
);
alter table grade_bands enable row level security;
create policy grade_bands_read on grade_bands for select to app_user
  using (school_id = app.school_id());
create policy grade_bands_admin_insert on grade_bands for insert to app_user
  with check (app.is_admin() and school_id = app.school_id());
create policy grade_bands_admin_update on grade_bands for update to app_user
  using (app.is_admin() and school_id = app.school_id())
  with check (app.is_admin() and school_id = app.school_id());
create policy grade_bands_admin_delete on grade_bands for delete to app_user
  using (app.is_admin() and school_id = app.school_id());
grant select, insert, update, delete on grade_bands to app_user;

create function app.grade_band(p_score numeric, p_school uuid) returns text
language sql stable security definer set search_path = public as $$
  select label from grade_bands
   where school_id = p_school and p_score between min_score and max_score
   order by min_score desc limit 1
$$;

-- Same formula as the baseline (002_functions.sql), plus a grade_band label per subject.
create or replace function student_summary(p_student uuid) returns jsonb language plpgsql as $$
declare
  v_att    jsonb;
  v_grades jsonb;
  v_due    numeric;
  v_paid   numeric;
  v_pend   numeric;
  v_school uuid;
  v_money  boolean := app.role() in ('admin', 'guardian');
begin
  if not app.can_view_student(p_student) then
    raise exception 'student not found or not permitted' using errcode = '42501';
  end if;
  perform app.log_read(p_student, 'student_summary');
  select school_id into v_school from people where id = p_student;

  select jsonb_build_object(
           'total',    count(*),
           'present',  count(*) filter (where status = 'present'),
           'late',     count(*) filter (where status = 'late'),
           'absent',   count(*) filter (where status = 'absent'),
           'excused',  count(*) filter (where status = 'excused'),
           'rate_pct', round(100.0 * count(*) filter (where status in ('present', 'late'))
                             / nullif(count(*), 0), 1))
    into v_att
    from attendance_records where student_id = p_student;

  select coalesce(jsonb_agg(jsonb_build_object(
           'class_section_id', class_section_id, 'subject', subject, 'running_grade', g,
           'grade_band', app.grade_band(g, v_school))
           order by subject), '[]')
    into v_grades
    from (select a.class_section_id, a.subject,
                 round(100 * sum(gr.score / a.max_score * a.weight) / sum(a.weight), 1) as g
          from grades gr join assessments a on a.id = gr.assessment_id
          where gr.student_id = p_student and gr.score is not null
          group by a.class_section_id, a.subject) x;

  if v_money then
    select coalesce(sum(amount_due), 0) into v_due
      from invoices where student_id = p_student and status <> 'void';
    select coalesce(sum(p.amount) filter (where p.status = 'succeeded'), 0),
           coalesce(sum(p.amount) filter (where p.status = 'pending'), 0)
      into v_paid, v_pend
      from payments p join invoices i on i.id = p.invoice_id
      where i.student_id = p_student and i.status <> 'void';
  end if;

  return jsonb_build_object(
    'student_id', p_student,
    'attendance', v_att,
    'grades',     v_grades,
    'balance',    case when v_money then v_due - v_paid end,
    'pending_payments', case when v_money then v_pend end);
end $$;

create table fee_items (
  id             uuid primary key default gen_random_uuid(),
  school_id      uuid not null references schools (id),
  name           text not null,
  default_amount numeric(12,2) not null check (default_amount >= 0),
  active         boolean not null default true,
  created_at     timestamptz not null default now(),
  unique (id, school_id)
);
alter table fee_items enable row level security;
create policy fee_items_admin on fee_items for all to app_user
  using (app.is_admin() and school_id = app.school_id())
  with check (app.is_admin() and school_id = app.school_id());
grant select, insert, update, delete on fee_items to app_user;

alter table invoices add column fee_item_id uuid;
alter table invoices add constraint invoices_fee_item_fk
  foreign key (fee_item_id, school_id) references fee_items (id, school_id);
