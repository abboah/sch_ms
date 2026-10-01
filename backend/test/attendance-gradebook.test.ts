import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => { h = await setup(); });
after(async () => { await h.close(); });

const mathsMon = id('per:6A:maths:1');
const six = id('sec:6A');
const at = (time: string) => `2026-10-05T${time}Z`;

describe('dashboards (before anything is marked today)', () => {
  test('admin overview: unmarked registers, money owed, overdue count, latest notices', async () => {
    const r = await h.call('GET', '/admin/overview', { as: await h.login('esi') });
    assert.equal(r.body.date, '2026-10-05');
    assert.equal(r.body.attendance_rate_today_pct, null);
    assert.deepEqual(r.body.registers_unmarked.map((x: any) => x.class_section.name).sort(), ['6A', '6B']);
    assert.equal(r.body.fees_outstanding, '4300.00'); // 600 + 1850 + 1850; a pending payment does not count
    assert.equal(r.body.invoices_overdue, 1);
    assert.deepEqual(r.body.recent_announcements.map((a: any) => a.title), ['English reading', 'Science museum trip', 'Mid-term break']);
  });

  test('teacher today: their periods with the register state', async () => {
    const r = await h.call('GET', '/teacher/today', { as: await h.login('kwame') });
    assert.equal(r.body.date, '2026-10-05');
    assert.equal(r.body.periods.length, 1);
    assert.deepEqual([r.body.periods[0].period.subject, r.body.periods[0].register, r.body.periods[0].enrolled], ['Maths', 'unmarked', 28]);
    const past = await h.call('GET', '/teacher/today?date=2026-09-28', { as: await h.login('kwame') });
    assert.deepEqual([past.body.periods[0].register, past.body.periods[0].marked], ['partial', 2]);
  });

  test('parents and admins do not get a teacher\'s day', async () => {
    assert.equal((await h.call('GET', '/teacher/today', { as: await h.login('akua') })).status, 403);
    assert.equal((await h.call('GET', '/admin/overview', { as: await h.login('kwame') })).status, 403);
  });
});

describe('the register', () => {
  test('lists every enrolled pupil, marked or not', async () => {
    const r = await h.call('GET', `/class_sections/${six}/attendance?date=2026-09-28&period_id=${mathsMon}`, { as: await h.login('kwame') });
    assert.equal(r.body.entries.length, 28);
    const byName = Object.fromEntries(r.body.entries.map((e: any) => [e.student.full_name, e.status]));
    assert.equal(byName['Kofi Asante'], 'present');
    assert.equal(byName['Kweku Sarpong'], null);
    assert.equal(r.body.term_closed, false);
  });

  test('parents cannot open a register; a teacher of another class gets 404', async () => {
    assert.equal((await h.call('GET', `/class_sections/${six}/attendance?date=2026-09-28`, { as: await h.login('akua') })).status, 403);
    assert.equal((await h.call('GET', `/class_sections/${six}/attendance?date=2026-09-28`, { as: await h.login('abena') })).status, 404);
  });
});

describe('marking attendance (and offline sync)', () => {
  const entry = (who: string, status: string, time = '07:50:00') => ({ student_id: id(who), status, marked_at: at(time) });

  test('a whole period is marked at once and reads back', async () => {
    const as = await h.login('kwame');
    const r = await h.call('PUT', `/class_sections/${six}/attendance`, {
      as, json: { date: '2026-10-05', period_id: mathsMon, entries: [entry('p:kweku', 'absent'), entry('p:adwoa', 'present'), entry('p:kofi', 'late')] },
    });
    assert.equal(r.status, 200);
    assert.equal(r.body.applied, 3);
    assert.equal(r.body.rejected, 0);
    const back = await h.call('GET', `/class_sections/${six}/attendance?date=2026-10-05&period_id=${mathsMon}`, { as });
    const byName = Object.fromEntries(back.body.entries.map((e: any) => [e.student.full_name, e.status]));
    assert.deepEqual([byName['Kweku Sarpong'], byName['Adwoa Ofori'], byName['Kofi Asante'], byName['Afia Nkrumah']], ['absent', 'present', 'late', null]);
    const today = await h.call('GET', '/teacher/today', { as });
    assert.deepEqual([today.body.periods[0].register, today.body.periods[0].marked], ['partial', 3]);
  });

  test('absent and late marks queue guardian notifications in the same transaction', async () => {
    const q = await h.db.asService((tx) =>
      tx.query(`select student_id, payload->>'status' as status from notification_outbox where kind = 'attendance.marked' order by id`),
    );
    const got = q.rows.map((x: any) => `${x.student_id}:${x.status}`);
    assert.ok(got.includes(`${id('p:kweku')}:absent`));
    assert.ok(got.includes(`${id('p:kofi')}:late`));
    assert.ok(!got.some((x: string) => x.startsWith(id('p:adwoa'))), 'present marks do not notify');
  });

  test('replaying the same batch is harmless (a retried offline sync)', async () => {
    const as = await h.login('kwame');
    const body = { date: '2026-10-05', period_id: mathsMon, entries: [entry('p:kweku', 'absent')] };
    const a = await h.call('PUT', `/class_sections/${six}/attendance`, { as, json: body, headers: { 'idempotency-key': 'sync-001' } });
    const b = await h.call('PUT', `/class_sections/${six}/attendance`, { as, json: body, headers: { 'idempotency-key': 'sync-001' } });
    assert.equal(b.headers.get('idempotent-replay'), 'true');
    assert.deepEqual(b.body, a.body);
    const n = await h.db.asService((tx) => tx.query(`select count(*)::int n from attendance_records where student_id = $1 and period_date = '2026-10-05'`, [id('p:kweku')]));
    assert.equal(n.rows[0]!.n, 1);
  });

  test('last write wins by the device\'s mark time: an older queued write never overwrites a newer one', async () => {
    const as = await h.login('kwame');
    const newer = await h.call('PUT', `/class_sections/${six}/attendance`, {
      as, json: { date: '2026-10-05', period_id: mathsMon, entries: [entry('p:afia', 'late', '07:55:00')] },
    });
    assert.equal(newer.body.results[0].outcome, 'applied');
    const older = await h.call('PUT', `/class_sections/${six}/attendance`, {
      as, json: { date: '2026-10-05', period_id: mathsMon, entries: [entry('p:afia', 'absent', '07:40:00')] },
    });
    assert.equal(older.body.results[0].outcome, 'stale');
    assert.equal(older.body.applied, 0);
    const row = await h.db.asService((tx) => tx.query(`select status from attendance_records where student_id = $1 and period_date = '2026-10-05'`, [id('p:afia')]));
    assert.equal(row.rows[0]!.status, 'late');
  });

  test('a mark time from the future is clamped to now + 5 minutes, so a wrong device clock cannot lock a record for long', async () => {
    const as = await h.login('kwame');
    await h.call('PUT', `/class_sections/${six}/attendance`, {
      as, json: { date: '2026-10-05', period_id: mathsMon, entries: [{ student_id: id('p:yawa'), status: 'absent', marked_at: '2031-01-01T00:00:00Z' }] },
    });
    const corrected = await h.call('PUT', `/class_sections/${six}/attendance`, {
      as, json: { date: '2026-10-05', period_id: mathsMon, entries: [entry('p:yawa', 'present', '08:06:00')] },
    });
    assert.equal(corrected.body.results[0].outcome, 'applied', 'a real correction after the clamp point still wins');
    const early = await h.call('PUT', `/class_sections/${six}/attendance`, {
      as, json: { date: '2026-10-05', period_id: mathsMon, entries: [entry('p:yawa', 'absent', '08:02:00')] },
    });
    assert.equal(early.body.results[0].outcome, 'stale');
  });

  test('one bad row does not lose the rest of a batch', async () => {
    const as = await h.login('kwame');
    const r = await h.call('PUT', `/class_sections/${six}/attendance`, {
      as, json: { date: '2026-10-05', period_id: mathsMon, entries: [entry('p:serwaa', 'present'), entry('p:kojot', 'present') /* a 6B pupil */, entry('p:kojob', 'present')] },
    });
    assert.deepEqual([r.body.applied, r.body.rejected], [2, 1]);
    assert.deepEqual(r.body.results.map((x: any) => x.outcome), ['applied', 'rejected', 'applied']);
    assert.equal(r.body.results[1].code, 'not_enrolled');
    const saved = await h.db.asService((tx) => tx.query(`select count(*)::int n from attendance_records where student_id = any($1::uuid[]) and period_date = '2026-10-05'`, [[id('p:serwaa'), id('p:kojob')]]));
    assert.equal(saved.rows[0]!.n, 2);
  });

  test('not a pupil at all is rejected per entry, with a code', async () => {
    const r = await h.call('PUT', `/class_sections/${six}/attendance`, {
      as: await h.login('kwame'), json: { date: '2026-10-05', period_id: mathsMon, entries: [entry('p:akua', 'present')] },
    });
    assert.equal(r.body.results[0].outcome, 'rejected');
  });

  test('parents cannot mark; teachers cannot mark another teacher\'s class', async () => {
    const body = { date: '2026-10-05', entries: [entry('p:kofi', 'present')] };
    assert.equal((await h.call('PUT', `/class_sections/${six}/attendance`, { as: await h.login('akua'), json: body })).status, 403);
    assert.equal((await h.call('PUT', `/class_sections/${six}/attendance`, { as: await h.login('abena'), json: body })).status, 404);
  });

  test('bad input is a 400 with field errors', async () => {
    const as = await h.login('kwame');
    const r = await h.call('PUT', `/class_sections/${six}/attendance`, { as, json: { date: '05/10/2026', entries: [] } });
    assert.equal(r.status, 400);
    assert.equal(r.body.code, 'validation_failed');
  });
});

describe('closed terms', () => {
  const sec5 = id('sec:5A25');
  const body = { date: '2025-06-02', entries: [{ student_id: id('p:kofi'), status: 'present', marked_at: at('08:00:00') }] };

  test('a teacher is locked out; an administrator can still correct history', async () => {
    const denied = await h.call('PUT', `/class_sections/${sec5}/attendance`, { as: await h.login('kwame'), json: body });
    assert.equal(denied.status, 403);
    assert.equal(denied.body.code, 'term_closed');
    const ok = await h.call('PUT', `/class_sections/${sec5}/attendance`, { as: await h.login('esi'), json: body });
    assert.equal(ok.body.applied, 1);
  });

  test('correcting one record: the teacher who can see it but not change it is told why', async () => {
    const rec = await h.db.asService((tx) => tx.query(`select id from attendance_records where class_section_id = $1`, [sec5]));
    const recordId = rec.rows[0]!.id;
    const denied = await h.call('PATCH', `/attendance_records/${recordId}`, { as: await h.login('kwame'), json: { status: 'absent' } });
    assert.equal(denied.status, 403);
    assert.equal(denied.body.code, 'term_closed');
    const ok = await h.call('PATCH', `/attendance_records/${recordId}`, { as: await h.login('esi'), json: { status: 'excused', note: 'Doctor\'s note' } });
    assert.equal(ok.body.status, 'excused');
    assert.equal(ok.body.note, 'Doctor\'s note');
    await h.db.asService((tx) => tx.query(`delete from attendance_records where class_section_id = $1`, [sec5])); // keep later numbers clean
  });
});

describe('correcting a record in an open term', () => {
  test('the teacher fixes a mistake; note can be cleared; unknown ids are 404', async () => {
    const as = await h.login('kwame');
    const rec = await h.db.asService((tx) => tx.query(`select id from attendance_records where student_id = $1 and period_date = '2026-10-05'`, [id('p:kweku')]));
    const recordId = rec.rows[0]!.id;
    const fixed = await h.call('PATCH', `/attendance_records/${recordId}`, { as, json: { status: 'excused', note: 'Called in sick' } });
    assert.deepEqual([fixed.body.status, fixed.body.note], ['excused', 'Called in sick']);
    const cleared = await h.call('PATCH', `/attendance_records/${recordId}`, { as, json: { note: null } });
    assert.equal(cleared.body.note, null);
    assert.equal(cleared.body.status, 'excused');
    assert.equal((await h.call('PATCH', `/attendance_records/${id('nope')}`, { as, json: { status: 'present' } })).status, 404);
    assert.equal((await h.call('PATCH', `/attendance_records/${recordId}`, { as: await h.login('akua'), json: { status: 'present' } })).status, 404);
  });
});

describe('attendance report', () => {
  const school = id('school:greenfield');

  test('per-pupil counts over a date range', async () => {
    const r = await h.call('GET', `/schools/${school}/attendance_report?from=2026-09-28&to=2026-10-02`, { as: await h.login('esi') });
    const kofi = r.body.rows.find((x: any) => x.student.full_name === 'Kofi Asante');
    assert.deepEqual([kofi.present, kofi.late, kofi.absent, kofi.excused, kofi.rate_pct], [3, 1, 0, 1, 80]);
  });

  test('CSV export has a header, quotes properly and is a download', async () => {
    const res = await h.call('GET', `/schools/${school}/attendance_report.csv?from=2026-09-28&to=2026-10-02`, { as: await h.login('esi') });
    assert.match(res.headers.get('content-type') ?? '', /text\/csv/);
    assert.match(res.headers.get('content-disposition') ?? '', /attendance_2026-09-28_2026-10-02\.csv/);
    const lines = (res.body as string).trim().split('\r\n');
    assert.equal(lines[0], 'Student,Section,Present,Late,Absent,Excused,Rate %');
    assert.ok(lines.includes('Kofi Asante,6A,3,1,0,1,80'));
  });

  test('only admin, and only for their own school', async () => {
    assert.equal((await h.call('GET', `/schools/${school}/attendance_report?from=2026-09-28&to=2026-10-02`, { as: await h.login('kwame') })).status, 403);
    assert.equal((await h.call('GET', `/schools/${id('school:riverside')}/attendance_report?from=2026-09-28&to=2026-10-02`, { as: await h.login('esi') })).status, 404);
  });
});

describe('gradebook', () => {
  test('the whole grid in one call, with weights and running averages', async () => {
    const r = await h.call('GET', `/class_sections/${six}/gradebook`, { as: await h.login('kwame') });
    assert.deepEqual(r.body.assessments.map((a: any) => [a.title, a.weight]), [['Quiz 1', 10], ['Fractions test', 25], ['Project', 20], ['Midterm', 45]]);
    assert.equal(r.body.rows.length, 28);
    const kofi = r.body.rows.find((x: any) => x.student.full_name === 'Kofi Asante');
    assert.equal(kofi.running_grade, 74.5);
    assert.equal(kofi.scores[id('as:6A:quiz1')], 8);
    assert.equal(kofi.scores[id('as:6A:midterm')], null);
    const nobody = r.body.rows.find((x: any) => x.student.full_name === 'Kweku Sarpong');
    assert.equal(nobody.running_grade, null);
  });

  test('admin may view; parents may not', async () => {
    assert.equal((await h.call('GET', `/class_sections/${six}/gradebook`, { as: await h.login('esi') })).status, 200);
    assert.equal((await h.call('GET', `/class_sections/${six}/gradebook`, { as: await h.login('akua') })).status, 403);
    assert.equal((await h.call('GET', `/class_sections/${six}/gradebook`, { as: await h.login('abena') })).status, 404);
  });

  test('weights of a subject cannot add up past 100', async () => {
    const as = await h.login('kwame');
    const over = await h.call('POST', `/class_sections/${six}/assessments`, { as, json: { subject: 'Maths', title: 'Extra', weight: 5, max_score: 10 } });
    assert.equal(over.status, 422);
    assert.equal(over.body.code, 'weights_exceed_100');
    const other = await h.call('POST', `/class_sections/${six}/assessments`, { as, json: { subject: 'Mental Maths', title: 'Drill 1', weight: 40, max_score: 20, due_date: '2026-10-09' } });
    assert.equal(other.status, 201);
    const raise = await h.call('PATCH', `/assessments/${other.body.id}`, { as, json: { weight: 101 } });
    assert.equal(raise.status, 400);
    const squeeze = await h.call('PATCH', `/assessments/${id('as:6A:midterm')}`, { as, json: { weight: 60 } });
    assert.equal(squeeze.status, 422);
    const ok = await h.call('PATCH', `/assessments/${other.body.id}`, { as, json: { weight: 50, title: 'Drill one', due_date: null } });
    assert.deepEqual([ok.body.weight, ok.body.title, ok.body.due_date], [50, 'Drill one', null]);
  });

  test('a closed term\'s gradebook is read-only; parents and other teachers cannot create columns', async () => {
    const closed = await h.call('POST', `/class_sections/${id('sec:5A25')}/assessments`, {
      as: await h.login('kwame'), json: { subject: 'Maths', title: 'Late', weight: 1, max_score: 10 },
    });
    assert.equal(closed.status, 403);
    assert.equal(closed.body.code, 'term_closed');
    assert.equal((await h.call('POST', `/class_sections/${six}/assessments`, { as: await h.login('akua'), json: { subject: 'Maths', title: 'x', weight: 1, max_score: 1 } })).status, 403);
    assert.equal((await h.call('POST', `/class_sections/${six}/assessments`, { as: await h.login('abena'), json: { subject: 'Maths', title: 'x', weight: 1, max_score: 1 } })).status, 404);
  });
});

describe('entering scores', () => {
  const mid = id('as:6A:midterm');

  test('batch entry with per-row outcomes; scores above the maximum are rejected', async () => {
    const as = await h.login('kwame');
    const r = await h.call('PATCH', `/assessments/${mid}/grades`, {
      as, json: { grades: [
        { student_id: id('p:kofi'), score: 70, comment: 'Steady' },
        { student_id: id('p:yaa'), score: 90 },
        { student_id: id('p:kweku'), score: 101 },   // over the 100 maximum
        { student_id: id('p:kojot'), score: 50 },    // a 6B pupil
      ] },
    });
    assert.deepEqual([r.body.applied, r.body.rejected], [2, 2]);
    assert.deepEqual(r.body.results.map((x: any) => x.code ?? x.outcome), ['applied', 'applied', 'score_out_of_range', 'not_enrolled']);

    const book = await h.call('GET', `/class_sections/${six}/gradebook`, { as });
    const kofi = book.body.rows.find((x: any) => x.student.full_name === 'Kofi Asante');
    assert.equal(kofi.running_grade, 72.5); // (8 + 18 + 15 + 31.5) / 100
    assert.equal(kofi.scores[mid], 70);
    assert.equal(book.body.rows.find((x: any) => x.student.full_name === 'Kweku Sarpong').scores[mid], null);
  });

  test('omitted fields are kept, null clears', async () => {
    const as = await h.login('kwame');
    await h.call('PATCH', `/assessments/${mid}/grades`, { as, json: { grades: [{ student_id: id('p:kofi'), comment: 'Much better' }] } });
    const kept = await h.call('GET', `/assessments/${mid}/grades`, { as });
    const row = kept.body.items.find((g: any) => g.student_id === id('p:kofi'));
    assert.deepEqual([row.score, row.comment], [70, 'Much better']);
    await h.call('PATCH', `/assessments/${mid}/grades`, { as, json: { grades: [{ student_id: id('p:kofi'), score: null }] } });
    const cleared = await h.call('GET', `/assessments/${mid}/grades`, { as });
    assert.equal(cleared.body.items.find((g: any) => g.student_id === id('p:kofi')).score, null);
  });

  test('locked after the term closes; another teacher cannot grade this class', async () => {
    const closed = await h.call('PATCH', `/assessments/${id('as:5A:exam')}/grades`, { as: await h.login('kwame'), json: { grades: [{ student_id: id('p:kofi'), score: 99 }] } });
    assert.equal(closed.status, 403);
    assert.equal(closed.body.code, 'term_closed');
    assert.equal((await h.call('PATCH', `/assessments/${mid}/grades`, { as: await h.login('abena'), json: { grades: [{ student_id: id('p:kofi'), score: 1 }] } })).status, 404);
    assert.equal((await h.call('PATCH', `/assessments/${mid}/grades`, { as: await h.login('akua'), json: { grades: [{ student_id: id('p:kofi'), score: 1 }] } })).status, 403);
  });
});
