/**
 * Database-level permission tests: the rules from the spec's "Who can see what" table, proven directly
 * against Postgres with no API in between. The API tests prove the endpoints; these prove the floor
 * they stand on, so a bug in a handler can never widen what a person can read.
 */
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { migrate } from '../src/db/migrate.ts';
import { openPglite } from '../src/db/pglite.ts';
import type { Db, Tx } from '../src/db/types.ts';
import { id } from './support/harness.ts';

let real: Db;
before(async () => {
  real = await openPglite();
  await migrate(real);
  await real.asService((tx) => tx.exec(readFileSync(new URL('../seed/seed.sql', import.meta.url), 'utf8')));
});
after(async () => { await real.close(); });

/** Service role (RLS bypassed): for setup and for checking what really ended up in a table. */
const db = { query: (sql: string, params?: unknown[]) => real.asService((tx) => tx.query(sql, params)) };
/** Run as a signed-in person: the non-superuser role, RLS in force. */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const as = <T>(_db: unknown, who: string, fn: (tx: Tx) => Promise<T>): Promise<T> => real.asUser(id(who), fn);

const count = (who: string, sql: string, params: unknown[] = []) =>
  as(db, who, async (tx) => (await tx.query(`select count(*)::int n from (${sql}) q`, params)).rows[0]!.n);
const rejects = (p: Promise<unknown>) => assert.rejects(p, (e: any) => e.code === '42501' || e.code === 'HR409' || /row-level security|permission denied|not permitted|unavailable|already booked|not found/i.test(e.message));

// ---------------------------------------------------------------- tenants
test('tenant isolation: each school sees only its own rows', async () => {
  const expected = { people: 4, class_sections: 1, enrollments: 1, invoices: 0, announcements: 0, grades: 0, attendance_records: 0 };
  for (const [t, n] of Object.entries(expected)) {
    assert.equal(await count('p:rb:admin', `select 1 from ${t}`), n, `Riverside admin on ${t}`);
  }
  assert.equal(await count('p:rb:admin', `select 1 from people where school_id = $1`, [id('school:greenfield')]), 0);
  assert.equal(await count('p:esi', `select 1 from people where school_id = $1`, [id('school:riverside')]), 0);
  assert.equal(await count('p:esi', `select 1 from schools`), 1);
});

test('tenant isolation: admin cannot write into another school', async () => {
  await rejects(as(db, 'p:esi', (tx) => tx.query(
    `insert into terms (school_id, name, starts_on, ends_on) values ($1, 'X', '2027-01-01', '2027-03-01')`,
    [id('school:riverside')])));
});

// ---------------------------------------------------------------- parent
test('parent sees only their own children (and both guardians see them)', async () => {
  assert.equal(await count('p:akua', `select 1 from people where role = 'student'`), 2);
  assert.equal(await count('p:kwabena', `select 1 from people where role = 'student'`), 2);
  assert.equal(await count('p:nana', `select 1 from people where role = 'student'`), 1);
  assert.equal(await count('p:samuel', `select 1 from people where id = $1`, [id('p:kofi')]), 0);
});

test('parent reads attendance, grades, invoices for own child only', async () => {
  assert.equal(await count('p:akua', `select 1 from attendance_records where student_id = $1`, [id('p:kofi')]), 5);
  assert.equal(await count('p:akua', `select 1 from attendance_records where student_id = $1`, [id('p:yaa')]), 0);
  assert.equal(await count('p:akua', `select 1 from grades`), 4);            // Kofi: 3 Maths + 1 locked-term exam
  assert.equal(await count('p:akua', `select 1 from invoices`), 2);          // Kofi, Ama
  assert.equal(await count('p:nana', `select 1 from invoices`), 1);
  assert.equal(await count('p:samuel', `select 1 from invoices where id = $1`, [id('inv:kofi')]), 0);
  assert.equal(await count('p:akua', `select 1 from payments`), 2);
  assert.equal(await count('p:nana', `select 1 from payments`), 1);          // her pending one
});

test('parent cannot write attendance, grades, invoices or payments', async () => {
  await rejects(as(db, 'p:akua', (tx) => tx.query(
    `insert into attendance_records (school_id, student_id, class_section_id, period_date, status, marked_by)
     values ($1, $2, $3, '2026-10-05', 'present', $4)`,
    [id('school:greenfield'), id('p:kofi'), id('sec:6A'), id('p:akua')])));
  for (const sql of [
    `update grades set score = 100`,
    `update invoices set status = 'paid'`,
    `update payments set status = 'succeeded'`,
    `update attendance_records set status = 'present'`,
  ]) {
    const r = await as(db, 'p:akua', (tx) => tx.query(sql + ' returning 1'));
    assert.equal(r.rows.length, 0, sql);
  }
  const still = await db.query(`select status from invoices where id = $1`, [id('inv:kofi')]);
  assert.equal(still.rows[0]!.status, 'partial');
});

test('parent cannot call the payment webhook function', async () => {
  await assert.rejects(as(db, 'p:akua', (tx) => tx.query(
    `select apply_payment_webhook('X1', $1, 600, 'card', 'succeeded')`, [id('inv:kofi')])), /permission denied/);
});

// ---------------------------------------------------------------- teacher
test('teacher sees exactly their own students, not other sections', async () => {
  assert.equal(await count('p:kwame', `select 1 from people where role = 'student'`), 28);
  assert.equal(await count('p:abena', `select 1 from people where role = 'student'`), 27);
  assert.equal(await count('p:yaw', `select 1 from people where role = 'student'`), 55);   // 6A + 6B
  assert.equal(await count('p:kwame', `select 1 from people where id = $1`, [id('p:kojot')]), 0);
  assert.equal(await count('p:kwame', `select 1 from class_sections`), 2);   // 6A + closed 5A
});

test('teacher has no access to fees, audit data or teachers outside their sections', async () => {
  assert.equal(await count('p:kwame', `select 1 from invoices`), 0);
  assert.equal(await count('p:kwame', `select 1 from payments`), 0);
  assert.equal(await count('p:kwame', `select 1 from people where role = 'teacher'`), 2);  // self + Yaw, who shares 6A
  assert.equal(await count('p:kwame', `select 1 from audit_log`), 0);
  assert.equal(await count('p:kwame', `select 1 from people where id = $1`, [id('p:abena')]), 0);   // shares no section
});

test('teacher marks attendance for own class, not another', async () => {
  const ins = (who: string, student: string, section: string) => as(db, who, (tx) => tx.query(
    `insert into attendance_records (school_id, student_id, class_section_id, period_date, status, marked_by)
     values ($1, $2, $3, '2026-10-05', 'present', $4)`,
    [id('school:greenfield'), id(student), id(section), id(who)]));
  await ins('p:kwame', 'p:kweku', 'sec:6A');
  await rejects(ins('p:kwame', 'p:kojot', 'sec:6B'));        // not their class
  await rejects(ins('p:abena', 'p:kweku', 'sec:6A'));        // not their class either
  await rejects(ins('p:kwame', 'p:nii', 'sec:6A'));          // student not enrolled there
});

test('teacher cannot mark attendance as someone else', async () => {
  await rejects(as(db, 'p:kwame', (tx) => tx.query(
    `insert into attendance_records (school_id, student_id, class_section_id, period_date, status, marked_by)
     values ($1, $2, $3, '2026-10-06', 'present', $4)`,
    [id('school:greenfield'), id('p:kweku'), id('sec:6A'), id('p:abena')])));
});

test('teacher edits own grades; a closed term is locked', async () => {
  const r = await as(db, 'p:kwame', (tx) => tx.query(
    `insert into grades (school_id, assessment_id, student_id, score) values ($1, $2, $3, 12)`,
    [id('school:greenfield'), id('as:6A:project'), id('p:kweku')]));
  assert.equal(r.rowCount, 1);
  const upd = await as(db, 'p:kwame', (tx) => tx.query(
    `update grades set score = 16 where assessment_id = $1 and student_id = $2 returning score`,
    [id('as:6A:project'), id('p:kweku')]));
  assert.equal(upd.rows.length, 1);
  // closed term: update silently matches nothing? No: USING requires the section to be open for attendance,
  // and for grades can_grade() in WITH CHECK blocks it.
  await rejects(as(db, 'p:kwame', (tx) => tx.query(
    `update grades set score = 99 where assessment_id = $1`, [id('as:5A:exam')])));
  await rejects(as(db, 'p:kwame', (tx) => tx.query(
    `insert into assessments (school_id, class_section_id, subject, title, weight, max_score)
     values ($1, $2, 'Maths', 'Late add', 10, 10)`, [id('school:greenfield'), id('sec:5A25')])));
  const exam = await db.query(`select score from grades where assessment_id = $1`, [id('as:5A:exam')]);
  assert.equal(Number(exam.rows[0]!.score), 65);
});

test('teacher cannot grade another teacher\'s section or a non-enrolled student', async () => {
  await rejects(as(db, 'p:abena', (tx) => tx.query(
    `insert into grades (school_id, assessment_id, student_id, score) values ($1, $2, $3, 5)`,
    [id('school:greenfield'), id('as:6A:quiz1'), id('p:kojot')])));
  await rejects(as(db, 'p:kwame', (tx) => tx.query(
    `insert into grades (school_id, assessment_id, student_id, score) values ($1, $2, $3, 5)`,
    [id('school:greenfield'), id('as:6A:quiz1'), id('p:nii')])));
});

test('teacher can announce to own class but not school-wide', async () => {
  const post = (section: string | null) => as(db, 'p:kwame', (tx) => tx.query(
    `insert into announcements (school_id, author_id, class_section_id, title, body, published_at)
     values ($1, $2, $3, 'Hi', 'Hello', now())`, [id('school:greenfield'), id('p:kwame'), section]));
  await post(id('sec:6A'));
  await rejects(post(null));
  await rejects(post(id('sec:6B')));
});

// ---------------------------------------------------------------- admin
test('admin reads everything in school but cannot hard-delete enrollments', async () => {
  assert.equal(await count('p:esi', `select 1 from people where role = 'student'`), 65);
  const del = await as(db, 'p:esi', (tx) => tx.query(`delete from enrollments returning 1`));
  assert.equal(del.rows.length, 0);
  assert.equal((await db.query(`select count(*)::int n from enrollments where school_id = $1`, [id('school:greenfield')])).rows[0]!.n > 0, true);
  const soft = await as(db, 'p:esi', (tx) => tx.query(
    `update enrollments set status = 'withdrawn' where student_id = $1 and class_section_id = $2 returning status`,
    [id('p:afia'), id('sec:6A')]));
  assert.equal(soft.rows[0]!.status, 'withdrawn');
});

test('admin can edit attendance even in a closed term', async () => {
  await as(db, 'p:esi', (tx) => tx.query(
    `insert into attendance_records (school_id, student_id, class_section_id, period_date, status, marked_by)
     values ($1, $2, $3, '2025-06-02', 'present', $4)`,
    [id('school:greenfield'), id('p:kofi'), id('sec:5A25'), id('p:esi')]));
  await db.query(`delete from attendance_records where period_date = '2025-06-02'`);   // keep later tests' data clean
});

test('admin views grades but cannot write them', async () => {
  assert.ok(await count('p:esi', `select 1 from grades`) > 0);
  await rejects(as(db, 'p:esi', (tx) => tx.query(
    `insert into grades (school_id, assessment_id, student_id, score) values ($1, $2, $3, 1)`,
    [id('school:greenfield'), id('as:6A:quiz1'), id('p:kweku')])));
});

test('admin audits message threads but cannot send messages', async () => {
  assert.equal(await count('p:esi', `select 1 from messages`), 2);
  await rejects(as(db, 'p:esi', (tx) => tx.query(
    `insert into messages (school_id, thread_id, sender_id, body) values ($1, $2, $3, 'hi')`,
    [id('school:greenfield'), id('thr:kofi'), id('p:esi')])));
});

// ---------------------------------------------------------------- messaging
test('messages: participants only, sender must be self, no edits', async () => {
  assert.equal(await count('p:akua', `select 1 from messages`), 2);
  assert.equal(await count('p:kwame', `select 1 from messages`), 2);
  assert.equal(await count('p:samuel', `select 1 from messages`), 0);
  assert.equal(await count('p:abena', `select 1 from messages`), 0);
  await as(db, 'p:akua', (tx) => tx.query(
    `insert into messages (school_id, thread_id, sender_id, body) values ($1, $2, $3, 'Thank you')`,
    [id('school:greenfield'), id('thr:kofi'), id('p:akua')]));
  await rejects(as(db, 'p:akua', (tx) => tx.query(
    `insert into messages (school_id, thread_id, sender_id, body) values ($1, $2, $3, 'spoof')`,
    [id('school:greenfield'), id('thr:kofi'), id('p:kwame')])));
  await rejects(as(db, 'p:samuel', (tx) => tx.query(
    `insert into messages (school_id, thread_id, sender_id, body) values ($1, $2, $3, 'intrude')`,
    [id('school:greenfield'), id('thr:kofi'), id('p:samuel')])));
  const edit = await as(db, 'p:akua', (tx) => tx.query(`update messages set body = 'x' returning 1`));
  assert.equal(edit.rows.length, 0);
});

test('threads are always about a child the two parties share', async () => {
  const open = (who: string, student: string, teacher: string, guardian: string) => as(db, who, (tx) => tx.query(
    `insert into message_threads (school_id, student_id, teacher_id, guardian_id) values ($1, $2, $3, $4)`,
    [id('school:greenfield'), id(student), id(teacher), id(guardian)]));
  await open('p:nana', 'p:yaa', 'p:kwame', 'p:nana');                         // Kwame teaches Yaa
  await rejects(open('p:nana', 'p:yaa', 'p:abena', 'p:nana'));                // Abena does not
  await rejects(open('p:nana', 'p:kofi', 'p:kwame', 'p:nana'));               // not her child
  await rejects(open('p:kwame', 'p:kojot', 'p:kwame', 'p:samuel'));           // Kwame doesn't teach Kojo
});

// ---------------------------------------------------------------- announcements
test('announcements: drafts hidden, class-only scoped to that class', async () => {
  const titles = async (who: string) => as(db, who, async (tx) =>
    (await tx.query(`select title from announcements order by title`)).rows.map((r) => r.title));
  const akua = await titles('p:akua');
  assert.ok(akua.includes('Mid-term break') && akua.includes('Science museum trip'));
  assert.ok(!akua.includes('English reading'), '6B-only notice leaked to a 6A parent');
  assert.ok(!akua.includes('Term 2 fees notice'), 'draft leaked');
  const samuel = await titles('p:samuel');
  assert.ok(samuel.includes('English reading'));
  assert.ok(!samuel.includes('Term 2 fees notice'));
  assert.ok((await titles('p:esi')).includes('Term 2 fees notice'));   // admin sees drafts
});

test('permission slip: reply per child, only for own child', async () => {
  const reply = (who: string, student: string) => as(db, who, (tx) => tx.query(
    `insert into announcement_responses (school_id, announcement_id, student_id, guardian_id, response)
     values ($1, $2, $3, $4, 'yes')`,
    [id('school:greenfield'), id('ann:trip'), id(student), id(who)]));
  await reply('p:akua', 'p:kofi');
  await rejects(reply('p:akua', 'p:yaa'));
  await rejects(as(db, 'p:akua', (tx) => tx.query(
    `insert into announcement_responses (school_id, announcement_id, student_id, guardian_id, response)
     values ($1, $2, $3, $4, 'yes')`,
    [id('school:greenfield'), id('ann:break'), id('p:kofi'), id('p:akua')])));   // no response required
});

// ---------------------------------------------------------------- conferences
test('conference booking: only via function, only own child\'s teacher, no double-booking', async () => {
  const slot = async (time: string) => (await db.query(
    `select id from conference_slots where starts_at = $1`, [`2026-10-24 ${time}+00`])).rows[0]!.id;
  const s0930 = await slot('09:30'), s0915 = await slot('09:15'), s1000 = await slot('10:00'), s1015 = await slot('10:15');
  assert.equal(await count('p:nana', `select 1 from conference_slots`), 11);     // 12 slots minus Akua's booking
  assert.equal(await count('p:akua', `select 1 from conference_slots`), 12);     // plus her own
  assert.equal(await count('p:samuel', `select 1 from conference_slots`), 0);    // Kwame doesn't teach Kojo
  await as(db, 'p:nana', (tx) => tx.query(`select book_conference_slot($1, $2)`, [s0930, id('p:yaa')]));
  await rejects(as(db, 'p:nana', (tx) => tx.query(`select book_conference_slot($1, $2)`, [s0915, id('p:yaa')])));
  await rejects(as(db, 'p:samuel', (tx) => tx.query(`select book_conference_slot($1, $2)`, [s1000, id('p:kojot')])));
  await rejects(as(db, 'p:nana', (tx) => tx.query(`select book_conference_slot($1, $2)`, [s1015, id('p:kofi')])));
  const direct = await as(db, 'p:nana', (tx) => tx.query(
    `update conference_slots set starts_at = starts_at + interval '1 hour' returning 1`));
  assert.equal(direct.rows.length, 0);
});

// ---------------------------------------------------------------- audit + summary
test('student_summary: numbers match the mock data and the read is audited', async () => {
  const { rows } = await as(db, 'p:akua', (tx) => tx.query(`select student_summary($1) s`, [id('p:kofi')]));
  const s = rows[0]!.s;
  assert.deepEqual(s.attendance, { total: 5, present: 3, late: 1, absent: 0, excused: 1, rate_pct: 80 });
  const maths = s.grades.find((g: any) => g.subject === 'Maths' && g.class_section_id === id('sec:6A'));
  assert.equal(maths.running_grade, 74.5);
  assert.equal(s.balance, 600);
  const yaa = (await as(db, 'p:nana', (tx) => tx.query(`select student_summary($1) s`, [id('p:yaa')]))).rows[0]!.s;
  assert.equal(yaa.grades[0].running_grade, 89.1);
  assert.equal(yaa.balance, 1850);
  assert.equal(yaa.pending_payments, 500);

  const log = await db.query(`select actor_id, student_id, action from audit_log where student_id = $1`, [id('p:kofi')]);
  assert.ok(log.rows.some((r) => r.actor_id === id('p:akua') && r.action === 'read'));
});

test('student_summary: teachers get no money; strangers are refused and not logged', async () => {
  const t = (await as(db, 'p:kwame', (tx) => tx.query(`select student_summary($1) s`, [id('p:kofi')]))).rows[0]!.s;
  assert.equal(t.balance, null);
  assert.equal(t.pending_payments, null);
  await rejects(as(db, 'p:samuel', (tx) => tx.query(`select student_summary($1)`, [id('p:kofi')])));
  await rejects(as(db, 'p:abena', (tx) => tx.query(`select student_summary($1)`, [id('p:kofi')])));
  const log = await db.query(`select 1 from audit_log where actor_id in ($1, $2)`, [id('p:samuel'), id('p:abena')]);
  assert.equal(log.rows.length, 0);
});

test('audit log cannot be forged or read by non-admins', async () => {
  await as(db, 'p:samuel', (tx) => tx.query(`select app.log_read($1, 'forged')`, [id('p:kofi')]));   // not permitted: no row
  assert.equal((await db.query(`select 1 from audit_log where table_name = 'forged'`)).rows.length, 0);
  await rejects(as(db, 'p:akua', (tx) => tx.query(
    `insert into audit_log (school_id, actor_id, action, table_name) values ($1, $2, 'x', 'x')`,
    [id('school:greenfield'), id('p:akua')])));
  assert.equal(await count('p:akua', `select 1 from audit_log`), 0);
  assert.ok(await count('p:esi', `select 1 from audit_log`) > 0);
});

// ---------------------------------------------------------------- payments (service role)
test('webhook: partial, full, replay and out-of-order events', async () => {
  const call = (ref: string, amount: number, status: string) => db.query(
    `select apply_payment_webhook($1, $2, $3, 'card', $4) r`, [ref, id('inv:kojo'), amount, status]).then((r) => r.rows[0]!.r);

  assert.equal((await call('K-1', 1000, 'succeeded')).status, 'partial');
  assert.equal((await call('K-1', 1000, 'succeeded')).paid, 1000);            // replay: no double count
  assert.equal((await call('K-2', 850, 'pending')).status, 'partial');        // pending does not count
  assert.equal((await call('K-2', 850, 'succeeded')).status, 'paid');         // pending -> succeeded settles it
  assert.equal((await call('K-2', 850, 'pending')).status, 'paid');           // late stale event can't downgrade
  assert.equal((await call('K-2', 850, 'failed')).status, 'paid');
  const n = await db.query(`select count(*)::int n from payments where invoice_id = $1`, [id('inv:kojo')]);
  assert.equal(n.rows[0]!.n, 2);
  await assert.rejects(db.query(`select apply_payment_webhook('Z', $1, 1, 'card', 'succeeded')`,
    ['00000000-0000-0000-0000-000000000000']), /unknown invoice/);
});

test('data integrity: composite keys stop cross-school references', async () => {
  await assert.rejects(db.query(
    `insert into enrollments (school_id, student_id, class_section_id) values ($1, $2, $3)`,
    [id('school:greenfield'), id('p:rb:student'), id('sec:6A')]), /foreign key/);
});
