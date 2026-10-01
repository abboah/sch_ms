-- Seed: Greenfield Academy (mirrors docs/03-mock-data.md) plus Riverside Prep, a second
-- school that exists only so tests can prove tenants cannot see each other.
-- Ids are md5(key)::uuid so tests and the UI can refer to rows by stable key.

create function app.seed_id(k text) returns uuid language sql immutable as $$ select md5(k)::uuid $$;

insert into schools (id, name) values
  (app.seed_id('school:greenfield'), 'Greenfield Academy'),
  (app.seed_id('school:riverside'),  'Riverside Prep');

insert into terms (id, school_id, name, starts_on, ends_on, closed) values
  (app.seed_id('term:gf:2026t1'), app.seed_id('school:greenfield'), 'Term 1 2026', '2026-09-07', '2026-12-18', false),
  (app.seed_id('term:gf:2025t2'), app.seed_id('school:greenfield'), 'Term 2 2025', '2025-04-28', '2025-07-25', true),
  (app.seed_id('term:rb:2026t1'), app.seed_id('school:riverside'),  'Term 1 2026', '2026-09-07', '2026-12-18', false);

-- ---- people ---------------------------------------------------------------
insert into people (id, school_id, full_name, role)
select app.seed_id(k), app.seed_id('school:greenfield'), n, r::person_role
from (values
  ('p:esi',      'Esi Mensah',      'admin',    '+233200000001'),
  ('p:kwame',    'Kwame Boateng',   'teacher',  '+233200000002'),
  ('p:abena',    'Abena Owusu',     'teacher',  '+233200000003'),
  ('p:yaw',      'Yaw Darko',       'teacher',  '+233200000004'),
  ('p:comfort',  'Comfort Sefa',    'teacher',  '+233200000005'),
  ('p:akua',     'Akua Asante',     'guardian', '+233240000001'),
  ('p:kwabena',  'Kwabena Asante',  'guardian', '+233240000002'),
  ('p:nana',     'Nana Adjei',      'guardian', '+233240000003'),
  ('p:samuel',   'Samuel Tetteh',   'guardian', '+233240000004'),
  ('p:efua',     'Efua Quaye',      'guardian', '+233240000005'),
  ('p:kofi',     'Kofi Asante',     'student',  null),
  ('p:ama',      'Ama Asante',      'student',  null),
  ('p:yaa',      'Yaa Adjei',       'student',  null),
  ('p:kweku',    'Kweku Sarpong',   'student',  null),
  ('p:adwoa',    'Adwoa Ofori',     'student',  null),
  ('p:kojob',    'Kojo Bediako',    'student',  null),
  ('p:afia',     'Afia Nkrumah',    'student',  null),
  ('p:yawa',     'Yaw Amoah',       'student',  null),
  ('p:serwaa',   'Serwaa Gyamfi',   'student',  null),
  ('p:kojot',    'Kojo Tetteh',     'student',  null),
  ('p:nii',      'Nii Quaye',       'student',  null)
) v (k, n, r, ph);

insert into person_contacts (person_id, school_id, phone, email)
select app.seed_id(k), app.seed_id('school:greenfield'), ph,
       replace(lower(n), ' ', '.') || '@greenfield.edu.gh'
from (values
  ('p:esi', 'Esi Mensah', 'admin', '+233200000001'),
  ('p:kwame', 'Kwame Boateng', 'teacher', '+233200000002'),
  ('p:abena', 'Abena Owusu', 'teacher', '+233200000003'),
  ('p:yaw', 'Yaw Darko', 'teacher', '+233200000004'),
  ('p:comfort', 'Comfort Sefa', 'teacher', '+233200000005'),
  ('p:akua', 'Akua Asante', 'guardian', '+233240000001'),
  ('p:kwabena', 'Kwabena Asante', 'guardian', '+233240000002'),
  ('p:nana', 'Nana Adjei', 'guardian', '+233240000003'),
  ('p:samuel', 'Samuel Tetteh', 'guardian', '+233240000004'),
  ('p:efua', 'Efua Quaye', 'guardian', '+233240000005')
) v (k, n, r, ph);

-- rosters padded with placeholder pupils: 6A = 28, 6B = 27, 4B = 10
insert into people (id, school_id, full_name, role)
select app.seed_id('p:6A:' || n), app.seed_id('school:greenfield'), 'Pupil 6A-' || lpad(n::text, 2, '0'), 'student'::person_role
from generate_series(9, 28) n
union all
select app.seed_id('p:6B:' || n), app.seed_id('school:greenfield'), 'Pupil 6B-' || lpad(n::text, 2, '0'), 'student'
from generate_series(3, 27) n
union all
select app.seed_id('p:4B:' || n), app.seed_id('school:greenfield'), 'Pupil 4B-' || lpad(n::text, 2, '0'), 'student'
from generate_series(2, 10) n;

insert into people (id, school_id, full_name, role) values
  (app.seed_id('p:rb:admin'),    app.seed_id('school:riverside'), 'Rita Badu',      'admin'),
  (app.seed_id('p:rb:teacher'),  app.seed_id('school:riverside'), 'Tom Ankrah',     'teacher'),
  (app.seed_id('p:rb:guardian'), app.seed_id('school:riverside'), 'Grace Ofosu',    'guardian'),
  (app.seed_id('p:rb:student'),  app.seed_id('school:riverside'), 'Paa Ofosu',      'student');

insert into guardian_student (school_id, guardian_id, student_id, relationship, is_primary_contact)
select app.seed_id('school:greenfield'), app.seed_id(g), app.seed_id(s), rel, prim
from (values
  ('p:akua',    'p:kofi',  'mother', true),
  ('p:akua',    'p:ama',   'mother', true),
  ('p:kwabena', 'p:kofi',  'father', false),
  ('p:kwabena', 'p:ama',   'father', false),
  ('p:nana',    'p:yaa',   'grandmother', true),
  ('p:samuel',  'p:kojot', 'father', true),
  ('p:efua',    'p:nii',   'mother', true)
) v (g, s, rel, prim);
insert into guardian_student (school_id, guardian_id, student_id, is_primary_contact)
values (app.seed_id('school:riverside'), app.seed_id('p:rb:guardian'), app.seed_id('p:rb:student'), true);

-- ---- sections -------------------------------------------------------------
insert into class_sections (id, school_id, term_id, name, grade_level, homeroom_teacher_id) values
  (app.seed_id('sec:6A'),   app.seed_id('school:greenfield'), app.seed_id('term:gf:2026t1'), '6A', '6', app.seed_id('p:kwame')),
  (app.seed_id('sec:6B'),   app.seed_id('school:greenfield'), app.seed_id('term:gf:2026t1'), '6B', '6', app.seed_id('p:abena')),
  (app.seed_id('sec:4B'),   app.seed_id('school:greenfield'), app.seed_id('term:gf:2026t1'), '4B', '4', app.seed_id('p:comfort')),
  (app.seed_id('sec:5A25'), app.seed_id('school:greenfield'), app.seed_id('term:gf:2025t2'), '5A', '5', null),
  (app.seed_id('sec:rb:1'), app.seed_id('school:riverside'),  app.seed_id('term:rb:2026t1'), '1A', '1', app.seed_id('p:rb:teacher'));

-- homeroom rows are added by trigger; add the subject teachers
insert into section_teachers (school_id, section_id, teacher_id, subject)
select app.seed_id('school:greenfield'), app.seed_id(s), app.seed_id(t), subj
from (values
  ('sec:6A',   'p:kwame', 'Maths'),
  ('sec:6B',   'p:abena', 'English'),
  ('sec:6A',   'p:yaw',   'Science'),
  ('sec:6B',   'p:yaw',   'Science'),
  ('sec:5A25', 'p:kwame', 'Maths')
) v (s, t, subj);

-- ---- enrollments ----------------------------------------------------------
insert into enrollments (school_id, student_id, class_section_id, status)
select app.seed_id('school:greenfield'), app.seed_id(k), app.seed_id('sec:6A'), 'active'::enrollment_status
from unnest(array['p:kofi','p:yaa','p:kweku','p:adwoa','p:kojob','p:afia','p:yawa','p:serwaa']) k
union all
select app.seed_id('school:greenfield'), app.seed_id('p:6A:' || n), app.seed_id('sec:6A'), 'active'::enrollment_status
from generate_series(9, 28) n
union all
select app.seed_id('school:greenfield'), app.seed_id(k), app.seed_id('sec:6B'), 'active'::enrollment_status
from unnest(array['p:kojot','p:nii']) k
union all
select app.seed_id('school:greenfield'), app.seed_id('p:6B:' || n), app.seed_id('sec:6B'), 'active'::enrollment_status
from generate_series(3, 27) n
union all
select app.seed_id('school:greenfield'), app.seed_id('p:ama'), app.seed_id('sec:4B'), 'active'::enrollment_status
union all
select app.seed_id('school:greenfield'), app.seed_id('p:4B:' || n), app.seed_id('sec:4B'), 'active'::enrollment_status
from generate_series(2, 10) n
union all
select app.seed_id('school:greenfield'), app.seed_id('p:kofi'), app.seed_id('sec:5A25'), 'completed'::enrollment_status
union all
select app.seed_id('school:riverside'), app.seed_id('p:rb:student'), app.seed_id('sec:rb:1'), 'active'::enrollment_status;

insert into section_teachers (school_id, section_id, teacher_id, subject)
values (app.seed_id('school:riverside'), app.seed_id('sec:rb:1'), app.seed_id('p:rb:teacher'), 'All subjects');

-- ---- timetable ------------------------------------------------------------
insert into periods (id, school_id, class_section_id, teacher_id, subject, weekday, starts_at, ends_at)
select app.seed_id('per:6A:maths:' || d), app.seed_id('school:greenfield'), app.seed_id('sec:6A'),
       app.seed_id('p:kwame'), 'Maths', d, time '08:00', time '08:45'
from generate_series(1, 5) d
union all
select app.seed_id('per:6B:eng:' || d), app.seed_id('school:greenfield'), app.seed_id('sec:6B'),
       app.seed_id('p:abena'), 'English', d, time '08:00', time '08:45'
from generate_series(1, 5) d
union all
select app.seed_id('per:6A:sci:' || d), app.seed_id('school:greenfield'), app.seed_id('sec:6A'),
       app.seed_id('p:yaw'), 'Science', d, time '09:00', time '09:45'
from unnest(array[2, 4]) d;

-- ---- attendance: Kofi P,P,L,P,A(excused); Yaa all present; 6B register unmarked --
insert into attendance_records (school_id, student_id, class_section_id, period_id, period_date, status, marked_by, note, marked_at)
select app.seed_id('school:greenfield'), app.seed_id('p:kofi'), app.seed_id('sec:6A'),
       app.seed_id('per:6A:maths:' || extract(isodow from v.d::date)::int),
       v.d::date, v.st::attendance_status, app.seed_id('p:kwame'), v.note, (v.d || ' 07:52+00')::timestamptz
from (values
  ('2026-09-28', 'present', null),
  ('2026-09-29', 'present', null),
  ('2026-09-30', 'late',    null),
  ('2026-10-01', 'present', null),
  ('2026-10-02', 'excused', 'Fever; note from parent')
) v (d, st, note);

insert into attendance_records (school_id, student_id, class_section_id, period_id, period_date, status, marked_by, marked_at)
select app.seed_id('school:greenfield'), app.seed_id('p:yaa'), app.seed_id('sec:6A'),
       app.seed_id('per:6A:maths:' || extract(isodow from d::date)::int), d::date, 'present'::attendance_status, app.seed_id('p:kwame'), (d || ' 07:53+00')::timestamptz
from unnest(array['2026-09-28','2026-09-29','2026-09-30','2026-10-01','2026-10-02']) d;

-- ---- gradebook: 6A Maths --------------------------------------------------
insert into assessments (id, school_id, class_section_id, subject, title, weight, max_score, due_date)
select app.seed_id(k), app.seed_id('school:greenfield'), app.seed_id('sec:6A'), 'Maths', t, w, m, d::date
from (values
  ('as:6A:quiz1',    'Quiz 1',         10, 10,  '2026-09-18'),
  ('as:6A:fractions','Fractions test', 25, 100, '2026-10-02'),
  ('as:6A:project',  'Project',        20, 20,  '2026-10-16'),
  ('as:6A:midterm',  'Midterm',        45, 100, '2026-11-06')
) v (k, t, w, m, d);

insert into grades (school_id, assessment_id, student_id, score)
select app.seed_id('school:greenfield'), app.seed_id(a), app.seed_id(s), sc
from (values
  ('as:6A:quiz1',     'p:kofi', 8),   ('as:6A:quiz1',     'p:yaa', 9),
  ('as:6A:fractions', 'p:kofi', 72),  ('as:6A:fractions', 'p:yaa', 88),
  ('as:6A:project',   'p:kofi', 15),  ('as:6A:project',   'p:yaa', 18)
) v (a, s, sc);

-- a locked (closed-term) assessment for testing the term lock
insert into assessments (id, school_id, class_section_id, subject, title, weight, max_score, due_date)
values (app.seed_id('as:5A:exam'), app.seed_id('school:greenfield'), app.seed_id('sec:5A25'),
        'Maths', 'End of term exam', 100, 100, '2025-07-18');
insert into grades (school_id, assessment_id, student_id, score)
values (app.seed_id('school:greenfield'), app.seed_id('as:5A:exam'), app.seed_id('p:kofi'), 65);

-- ---- fees ----------------------------------------------------------------
insert into invoices (id, school_id, student_id, term_id, description, amount_due, due_date)
select app.seed_id(k), app.seed_id('school:greenfield'), app.seed_id(s), app.seed_id('term:gf:2026t1'),
       'Tuition', amt, d::date
from (values
  ('inv:kofi',  'p:kofi',  1850, '2026-09-30'),
  ('inv:ama',   'p:ama',   1650, '2026-09-30'),
  ('inv:yaa',   'p:yaa',   1850, '2026-10-15'),
  ('inv:kojo',  'p:kojot', 1850, '2026-10-15')
) v (k, s, amt, d);

-- payments go through the same function the gateway webhook uses
select apply_payment_webhook('PSK-0001', app.seed_id('inv:kofi'), 1250, 'mtn_momo', 'succeeded');
select apply_payment_webhook('PSK-0002', app.seed_id('inv:ama'),  1650, 'card',     'succeeded');
select apply_payment_webhook('PSK-0003', app.seed_id('inv:yaa'),   500, 'mtn_momo', 'pending');

-- ---- messaging -------------------------------------------------------------
insert into message_threads (id, school_id, student_id, teacher_id, guardian_id)
values (app.seed_id('thr:kofi'), app.seed_id('school:greenfield'), app.seed_id('p:kofi'),
        app.seed_id('p:kwame'), app.seed_id('p:akua'));
insert into messages (school_id, thread_id, sender_id, body, created_at) values
  (app.seed_id('school:greenfield'), app.seed_id('thr:kofi'), app.seed_id('p:akua'),
   'Kofi was out Friday with a fever. Note attached.', '2026-10-02 18:10+00'),
  (app.seed_id('school:greenfield'), app.seed_id('thr:kofi'), app.seed_id('p:kwame'),
   'Thanks, marked excused. He can catch up on the fractions worksheet.', '2026-10-02 19:02+00');

-- ---- announcements, homework ------------------------------------------------
insert into announcements (id, school_id, author_id, class_section_id, title, body, requires_response, published_at) values
  (app.seed_id('ann:break'), app.seed_id('school:greenfield'), app.seed_id('p:esi'), null,
   'Mid-term break', 'School closes Fri 23 Oct and reopens Mon 2 Nov.', false, '2026-10-01 08:00+00'),
  (app.seed_id('ann:trip'),  app.seed_id('school:greenfield'), app.seed_id('p:esi'), null,
   'Science museum trip', 'Trip on 13 Nov. Please reply by 6 Nov.', true, '2026-10-01 08:30+00'),
  (app.seed_id('ann:6b'),    app.seed_id('school:greenfield'), app.seed_id('p:abena'), app.seed_id('sec:6B'),
   'English reading', 'Class 6B: bring your reader on Monday.', false, '2026-10-02 09:00+00'),
  (app.seed_id('ann:draft'), app.seed_id('school:greenfield'), app.seed_id('p:esi'), null,
   'Term 2 fees notice', 'Draft, not yet published.', false, null);

insert into homework (school_id, class_section_id, title, body, due_date, posted_by) values
  (app.seed_id('school:greenfield'), app.seed_id('sec:6A'), 'Exercises 4.2 to 4.5', 'Show your working.', '2026-10-08', app.seed_id('p:kwame')),
  (app.seed_id('school:greenfield'), app.seed_id('sec:6B'), 'Read Chapter 3', 'Write 150 words on it.',   '2026-10-09', app.seed_id('p:abena'));

-- ---- conferences: Kwame, Sat 24 Oct, 09:00 to 12:00, 15-minute slots --------
insert into conference_slots (school_id, teacher_id, starts_at, ends_at)
select app.seed_id('school:greenfield'), app.seed_id('p:kwame'), t, t + interval '15 minutes'
from generate_series(timestamptz '2026-10-24 09:00+00', timestamptz '2026-10-24 11:45+00', interval '15 minutes') t;
update conference_slots
   set booked_by_guardian_id = app.seed_id('p:akua'), student_id = app.seed_id('p:kofi')
 where teacher_id = app.seed_id('p:kwame') and starts_at = timestamptz '2026-10-24 09:15+00';

-- ---- notifications ------------------------------------------------------------
insert into push_tokens (person_id, token, platform)
values (app.seed_id('p:akua'), 'fcm-token-akua-1', 'android');
insert into notification_prefs (person_id)
select id from people where role = 'guardian';

drop function app.seed_id(text);
