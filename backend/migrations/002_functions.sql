-- Helper functions used by RLS policies. They are SECURITY DEFINER so they can read
-- the tables they protect without recursing into those tables' own policies.
-- The caller's identity comes from the `app.person_id` setting, which the API sets
-- per request (on Supabase, swap person_id() for a lookup of auth.uid()).

create function app.person_id() returns uuid language sql stable as $$
  select nullif(current_setting('app.person_id', true), '')::uuid
$$;

create function app.school_id() returns uuid language sql stable security definer
set search_path = public as $$
  select school_id from people where id = app.person_id()
$$;

create function app.role() returns person_role language sql stable security definer
set search_path = public as $$
  select role from people where id = app.person_id()
$$;

create function app.is_admin() returns boolean language sql stable as $$
  select coalesce(app.role() = 'admin', false)
$$;

create function app.teaches_section(sec uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from section_teachers
                 where section_id = sec and teacher_id = app.person_id())
$$;

create function app.teacher_teaches(t uuid, stu uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from section_teachers st
                 join enrollments e on e.class_section_id = st.section_id and e.status = 'active'
                 where st.teacher_id = t and e.student_id = stu)
$$;

create function app.teaches_student(stu uuid) returns boolean language sql stable as $$
  select app.teacher_teaches(app.person_id(), stu)
$$;

create function app.guardian_of(g uuid, stu uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from guardian_student where guardian_id = g and student_id = stu)
$$;

create function app.guardian_of(stu uuid) returns boolean language sql stable as $$
  select app.guardian_of(app.person_id(), stu)
$$;

create function app.teaches_a_child_of(g uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from guardian_student gs
                 where gs.guardian_id = g and app.teaches_student(gs.student_id))
$$;

create function app.teacher_of_my_child(t uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from guardian_student gs
                 where gs.guardian_id = app.person_id() and app.teacher_teaches(t, gs.student_id))
$$;

create function app.child_in_section(sec uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from enrollments e
                 join guardian_student gs on gs.student_id = e.student_id
                 where e.class_section_id = sec and e.status = 'active'
                   and gs.guardian_id = app.person_id())
$$;

create function app.section_open(sec uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from class_sections cs join terms t on t.id = cs.term_id
                 where cs.id = sec and not t.closed)
$$;

create function app.enrolled_in(stu uuid, sec uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from enrollments
                 where student_id = stu and class_section_id = sec
                   and status in ('active', 'completed'))
$$;

create function app.can_mark(sec uuid, stu uuid) returns boolean language sql stable as $$
  select app.role() = 'teacher' and app.teaches_section(sec)
         and app.section_open(sec) and app.enrolled_in(stu, sec)
$$;

create function app.teaches_assessment(a uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from assessments x where x.id = a and app.teaches_section(x.class_section_id))
$$;

create function app.can_grade(a uuid, stu uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select app.role() = 'teacher' and exists (
    select 1 from assessments x
    where x.id = a and app.teaches_section(x.class_section_id)
      and app.section_open(x.class_section_id) and app.enrolled_in(stu, x.class_section_id))
$$;

create function app.guardian_of_invoice(inv uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from invoices i
                 join guardian_student gs on gs.student_id = i.student_id
                 where i.id = inv and gs.guardian_id = app.person_id())
$$;

create function app.in_thread(thr uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select exists (select 1 from message_threads
                 where id = thr and (teacher_id = app.person_id() or guardian_id = app.person_id()))
$$;

create function app.can_view_student(stu uuid) returns boolean language sql stable security definer
set search_path = public as $$
  select case app.role()
    when 'admin'    then exists (select 1 from people
                                 where id = stu and role = 'student' and school_id = app.school_id())
    when 'teacher'  then app.teaches_student(stu)
    when 'guardian' then app.guardian_of(stu)
    else false
  end
$$;

-- Read auditing. RLS cannot log SELECTs, so reads of a student's record go through
-- functions that call this. It refuses to log reads the caller could not make.
create function app.log_read(p_student uuid, p_what text) returns void language sql security definer
set search_path = public as $$
  insert into audit_log (school_id, actor_id, action, table_name, student_id)
  select app.school_id(), app.person_id(), 'read', p_what, p_student
  where app.can_view_student(p_student)
$$;

-- ---------------------------------------------------------------------------
-- Public API functions
-- ---------------------------------------------------------------------------

-- GET /students/:id/summary. SECURITY INVOKER: every query below runs under the
-- caller's RLS, so a teacher gets no balance and a parent only their own child.
-- attendance rate = (present + late) / all marked; excused counts as absent for the
-- rate but is reported separately. Running grade = weighted over graded assessments.
create function student_summary(p_student uuid) returns jsonb language plpgsql as $$
declare
  v_att    jsonb;
  v_grades jsonb;
  v_due    numeric;
  v_paid   numeric;
  v_pend   numeric;
  v_money  boolean := app.role() in ('admin', 'guardian');
begin
  if not app.can_view_student(p_student) then
    raise exception 'student not found or not permitted' using errcode = '42501';
  end if;
  perform app.log_read(p_student, 'student_summary');

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
           'class_section_id', class_section_id, 'subject', subject, 'running_grade', g)
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

-- Guardians book conference slots through this function rather than by UPDATE, so
-- they cannot change a slot's teacher or time.
create function book_conference_slot(p_slot uuid, p_student uuid) returns void
language plpgsql security definer set search_path = public as $$
declare v_teacher uuid;
begin
  if app.role() <> 'guardian' or not app.guardian_of(p_student) then
    raise exception 'not permitted' using errcode = '42501';
  end if;
  select teacher_id into v_teacher from conference_slots
   where id = p_slot and booked_by_guardian_id is null and school_id = app.school_id();
  if v_teacher is null or not app.teacher_teaches(v_teacher, p_student) then
    raise exception 'slot unavailable' using errcode = '42501';
  end if;
  update conference_slots
     set booked_by_guardian_id = app.person_id(), student_id = p_student
   where id = p_slot and booked_by_guardian_id is null;
end $$;

create function release_conference_slot(p_slot uuid) returns void
language sql security definer set search_path = public as $$
  update conference_slots set booked_by_guardian_id = null, student_id = null
   where id = p_slot and booked_by_guardian_id = app.person_id()
$$;

-- Payment gateway webhook handler. Service role only: the invoice changes state
-- here and nowhere else. Idempotent on provider_ref, and a settled payment is never
-- downgraded by a replayed or out-of-order event.
create function apply_payment_webhook(
  p_provider_ref text, p_invoice uuid, p_amount numeric,
  p_method payment_method, p_status payment_status
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_school uuid; v_due numeric; v_cur invoice_status; v_paid numeric; v_new invoice_status;
begin
  select school_id, amount_due, status into v_school, v_due, v_cur
    from invoices where id = p_invoice for update;
  if v_school is null then
    raise exception 'unknown invoice %', p_invoice using errcode = 'P0002';
  end if;

  insert into payments (school_id, invoice_id, provider_ref, amount, method, status, paid_at)
  values (v_school, p_invoice, p_provider_ref, p_amount, p_method, p_status,
          case when p_status = 'succeeded' then now() end)
  on conflict (provider_ref) do update
    set status = excluded.status, paid_at = excluded.paid_at
    where payments.status = 'pending' and excluded.status <> 'pending'
      and payments.invoice_id = excluded.invoice_id and payments.amount = excluded.amount;

  select coalesce(sum(amount), 0) into v_paid
    from payments where invoice_id = p_invoice and status = 'succeeded';

  v_new := case when v_cur = 'void' then 'void'
                when v_paid >= v_due then 'paid'
                when v_paid > 0 then 'partial'
                else 'unpaid' end;
  update invoices set status = v_new where id = p_invoice;

  return jsonb_build_object('invoice_id', p_invoice, 'status', v_new, 'paid', v_paid);
end $$;

revoke execute on function apply_payment_webhook(text, uuid, numeric, payment_method, payment_status)
  from public;
