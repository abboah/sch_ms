import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => { h = await setup(); });
after(async () => { await h.close(); });

describe('students: who sees whom', () => {
  test('a parent sees exactly their own children, with section, grade level and attendance rate', async () => {
    const r = await h.call('GET', '/students', { as: await h.login('akua') });
    assert.deepEqual(r.body.items.map((s: any) => s.full_name), ['Ama Asante', 'Kofi Asante']);
    const kofi = r.body.items.find((s: any) => s.full_name === 'Kofi Asante');
    assert.equal(kofi.class_section.name, '6A');
    assert.equal(kofi.grade_level, '6');
    assert.equal(kofi.attendance_rate_pct, 80);
  });

  test('a teacher sees their 28 pupils and pages through them without gaps or repeats', async () => {
    const as = await h.login('kwame');
    const seen: string[] = [];
    let cursor: string | null = null;
    let pages = 0;
    do {
      const r: any = await h.call('GET', `/students?limit=10${cursor ? `&cursor=${cursor}` : ''}`, { as });
      seen.push(...r.body.items.map((s: any) => s.id));
      cursor = r.body.next_cursor;
      pages++;
    } while (cursor);
    assert.equal(pages, 3);
    assert.equal(seen.length, 28);
    assert.equal(new Set(seen).size, 28);
  });

  test('search and section filters narrow the list', async () => {
    const as = await h.login('kwame');
    const r = await h.call('GET', '/students?q=KO', { as });
    assert.deepEqual(r.body.items.map((s: any) => s.full_name), ['Kofi Asante', 'Kojo Bediako']);
    const inSection = await h.call('GET', `/students?class_section_id=${id('sec:6B')}`, { as });
    assert.equal(inSection.body.items.length, 0, 'a 6A teacher has no access to 6B pupils');
  });

  test('admin sees the whole school, never another school', async () => {
    const r = await h.call('GET', '/students?limit=200', { as: await h.login('esi') });
    assert.equal(r.body.items.length, 65);
    assert.ok(!r.body.items.some((s: any) => s.full_name === 'Paa Ofosu'));
  });
});

describe('student profile', () => {
  test('a parent gets their child without the admin-only fields', async () => {
    const r = await h.call('GET', `/students/${id('p:kofi')}`, { as: await h.login('akua') });
    assert.equal(r.status, 200);
    assert.equal(r.body.guardians, undefined);
  });

  test('another family\'s child is a 404, not a 403', async () => {
    const r = await h.call('GET', `/students/${id('p:kofi')}`, { as: await h.login('samuel') });
    assert.equal(r.status, 404);
  });

  test('admin gets guardians with contacts and enrollment history', async () => {
    const r = await h.call('GET', `/students/${id('p:kofi')}`, { as: await h.login('esi') });
    assert.deepEqual(r.body.guardians.map((g: any) => g.guardian.full_name).sort(), ['Akua Asante', 'Kwabena Asante']);
    assert.equal(r.body.guardians[0].is_primary_contact, true);
    assert.equal(r.body.guardians[0].guardian.contact.phone, '+233240000001');
    assert.equal(r.body.enrollments.length, 2); // 6A and the completed 5A
  });

  test('every read of a child\'s record is written to the audit log', async () => {
    const before = await h.db.asService((tx) => tx.query(`select count(*)::int n from audit_log where actor_id = $1`, [id('p:nana')]));
    await h.call('GET', `/students/${id('p:yaa')}`, { as: await h.login('nana') });
    await h.call('GET', `/students/${id('p:yaa')}/grades`, { as: await h.login('nana') });
    const after = await h.db.asService((tx) => tx.query(`select table_name from audit_log where actor_id = $1 order by id`, [id('p:nana')]));
    assert.equal(after.rowCount - before.rows[0]!.n, 2);
    assert.deepEqual(after.rows.slice(-2).map((x: any) => x.table_name), ['student_detail', 'student_grades']);
  });
});

describe('student summary', () => {
  test('numbers match the mock data; money is a decimal string', async () => {
    const r = await h.call('GET', `/students/${id('p:kofi')}/summary`, { as: await h.login('akua') });
    assert.deepEqual(r.body.attendance, { total: 5, present: 3, late: 1, absent: 0, excused: 1, rate_pct: 80 });
    assert.equal(r.body.grades[0].running_grade, 74.5);
    assert.equal(r.body.balance, '600.00');
    assert.equal(r.body.pending_payments, '0.00');
  });

  test('a pending payment is reported but does not reduce the balance', async () => {
    const r = await h.call('GET', `/students/${id('p:yaa')}/summary`, { as: await h.login('nana') });
    assert.equal(r.body.balance, '1850.00');
    assert.equal(r.body.pending_payments, '500.00');
    assert.equal(r.body.grades[0].running_grade, 89.1);
  });

  test('teachers get no money; strangers get 404', async () => {
    const t = await h.call('GET', `/students/${id('p:kofi')}/summary`, { as: await h.login('kwame') });
    assert.equal(t.body.balance, null);
    assert.equal((await h.call('GET', `/students/${id('p:kofi')}/summary`, { as: await h.login('samuel') })).status, 404);
  });
});

describe('student attendance, grades, homework, invoices', () => {
  test('attendance history is newest first and can be date-ranged', async () => {
    const as = await h.login('akua');
    const all = await h.call('GET', `/students/${id('p:kofi')}/attendance`, { as });
    assert.deepEqual(all.body.items.map((a: any) => a.status), ['excused', 'present', 'late', 'present', 'present']);
    const some = await h.call('GET', `/students/${id('p:kofi')}/attendance?from=2026-09-30&to=2026-10-01`, { as });
    assert.deepEqual(some.body.items.map((a: any) => a.period_date), ['2026-10-01', '2026-09-30']);
  });

  test('grades list every assessment, including ones not yet scored, with the running grade', async () => {
    const r = await h.call('GET', `/students/${id('p:kofi')}/grades`, { as: await h.login('akua') });
    assert.equal(r.body.subjects.length, 1);
    const maths = r.body.subjects[0];
    assert.equal(maths.running_grade, 74.5);
    assert.deepEqual(maths.assessments.map((a: any) => [a.title, a.score]), [
      ['Quiz 1', 8], ['Fractions test', 72], ['Project', 15], ['Midterm', null],
    ]);
  });

  test('a closed term\'s grades are reachable by term id', async () => {
    const r = await h.call('GET', `/students/${id('p:kofi')}/grades?term_id=${id('term:gf:2025t2')}`, { as: await h.login('akua') });
    assert.equal(r.body.subjects[0].assessments[0].title, 'End of term exam');
    assert.equal(r.body.subjects[0].running_grade, 65);
  });

  test('homework for the child\'s classes carries the subject', async () => {
    const r = await h.call('GET', `/students/${id('p:kofi')}/homework`, { as: await h.login('akua') });
    assert.deepEqual(r.body.items.map((x: any) => [x.title, x.subject, x.due_date]), [['Exercises 4.2 to 4.5', 'Maths', '2026-10-08']]);
  });

  test('invoices show paid, outstanding, overdue and the payment trail', async () => {
    const r = await h.call('GET', `/students/${id('p:kofi')}/invoices`, { as: await h.login('akua') });
    const inv = r.body.items[0];
    assert.deepEqual([inv.amount_due, inv.amount_paid, inv.outstanding, inv.status, inv.overdue], ['1850.00', '1250.00', '600.00', 'partial', true]);
    assert.equal(inv.payments.length, 1);
    assert.equal(inv.payments[0].status, 'succeeded');
  });

  test('teachers cannot see invoices at all; other families get 404', async () => {
    assert.equal((await h.call('GET', `/students/${id('p:kofi')}/invoices`, { as: await h.login('kwame') })).status, 403);
    assert.equal((await h.call('GET', `/students/${id('p:kofi')}/invoices`, { as: await h.login('samuel') })).status, 404);
  });
});

describe('terms', () => {
  test('anyone lists terms; only admin creates or closes them', async () => {
    const list = await h.call('GET', '/terms', { as: await h.login('akua') });
    assert.deepEqual(list.body.items.map((t: any) => [t.name, t.closed]), [['Term 1 2026', false], ['Term 2 2025', true]]);

    const denied = await h.call('POST', '/terms', { as: await h.login('kwame'), json: { name: 'X', starts_on: '2027-01-05', ends_on: '2027-04-01' } });
    assert.equal(denied.status, 403);

    const created = await h.call('POST', '/terms', { as: await h.login('esi'), json: { name: 'Term 2 2026', starts_on: '2027-01-05', ends_on: '2027-04-01' } });
    assert.equal(created.status, 201);
    assert.equal(created.body.closed, false);
    const closed = await h.call('PATCH', `/terms/${created.body.id}`, { as: await h.login('esi'), json: { closed: true } });
    assert.equal(closed.body.closed, true);
  });
});

describe('class sections', () => {
  test('admin sees every section; a teacher only the ones they teach, with their subjects', async () => {
    const admin = await h.call('GET', '/class_sections', { as: await h.login('esi') });
    assert.deepEqual(admin.body.items.map((s: any) => s.name).sort(), ['4B', '5A', '6A', '6B']);
    const kwame = await h.call('GET', '/class_sections', { as: await h.login('kwame') });
    assert.deepEqual(kwame.body.items.map((s: any) => [s.name, s.subject]), [['5A', 'Maths'], ['6A', 'Homeroom, Maths']]);
  });

  test('section detail lists co-teachers, the roster and attendance', async () => {
    const r = await h.call('GET', `/class_sections/${id('sec:6A')}`, { as: await h.login('kwame') });
    assert.equal(r.body.roster.length, 28);
    assert.deepEqual(r.body.teachers.map((t: any) => t.person.full_name), ['Kwame Boateng', 'Kwame Boateng', 'Yaw Darko']);
    assert.equal(r.body.homeroom_teacher.full_name, 'Kwame Boateng');
    assert.equal(r.body.attendance_rate_pct, 90); // Kofi 4/5 + Yaa 5/5 = 9/10
  });

  test('a parent viewing a section sees only their own child in the roster', async () => {
    const r = await h.call('GET', `/class_sections/${id('sec:6A')}`, { as: await h.login('akua') });
    assert.deepEqual(r.body.roster.map((s: any) => s.full_name), ['Kofi Asante']);
  });

  test('a section the caller cannot see is 404', async () => {
    assert.equal((await h.call('GET', `/class_sections/${id('sec:6B')}`, { as: await h.login('kwame') })).status, 404);
  });

  test('admin creates a section and reassigns its homeroom teacher; a teacher cannot', async () => {
    const esi = await h.login('esi');
    const made = await h.call('POST', '/class_sections', {
      as: esi, json: { name: '3C', grade_level: '3', term_id: id('term:gf:2026t1'), homeroom_teacher_id: id('p:comfort') },
    });
    assert.equal(made.status, 201);
    assert.equal(made.body.homeroom_teacher.full_name, 'Comfort Sefa');
    const moved = await h.call('PATCH', `/class_sections/${made.body.id}`, { as: esi, json: { homeroom_teacher_id: id('p:abena') } });
    assert.equal(moved.body.homeroom_teacher.full_name, 'Abena Owusu');
    const cleared = await h.call('PATCH', `/class_sections/${made.body.id}`, { as: esi, json: { homeroom_teacher_id: null } });
    assert.equal(cleared.body.homeroom_teacher, undefined);
    assert.equal((await h.call('PATCH', `/class_sections/${made.body.id}`, { as: await h.login('kwame'), json: { name: 'x' } })).status, 403);
  });

  test('a guardian cannot be made a homeroom teacher (role typing)', async () => {
    const r = await h.call('POST', '/class_sections', {
      as: await h.login('esi'), json: { name: '3D', grade_level: '3', term_id: id('term:gf:2026t1'), homeroom_teacher_id: id('p:akua') },
    });
    assert.equal(r.status, 422);
    assert.equal(r.body.code, 'constraint_violated');
  });
});

describe('timetable', () => {
  test('replacing with the same timetable keeps period ids; adding one works', async () => {
    const esi = await h.login('esi');
    const cur = await h.call('GET', `/class_sections/${id('sec:6A')}/periods`, { as: esi });
    assert.equal(cur.body.items.length, 7); // Maths Mon-Fri + Science Tue/Thu
    const asInput = cur.body.items.map((p: any) => ({ subject: p.subject, teacher_id: p.teacher.id, weekday: p.weekday, starts_at: p.starts_at, ends_at: p.ends_at }));
    const same = await h.call('PUT', `/class_sections/${id('sec:6A')}/periods`, { as: esi, json: asInput });
    assert.deepEqual(same.body.items.map((p: any) => p.id).sort(), cur.body.items.map((p: any) => p.id).sort());

    const added = await h.call('PUT', `/class_sections/${id('sec:6A')}/periods`, {
      as: esi, json: [...asInput, { subject: 'Science', teacher_id: id('p:yaw'), weekday: 5, starts_at: '10:00', ends_at: '10:45' }],
    });
    assert.equal(added.body.items.length, 8);
    const removed = await h.call('PUT', `/class_sections/${id('sec:6A')}/periods`, { as: esi, json: asInput });
    assert.equal(removed.body.items.length, 7); // the unused one can go
  });

  test('a period that has attendance recorded cannot be removed', async () => {
    const esi = await h.login('esi');
    const cur = await h.call('GET', `/class_sections/${id('sec:6A')}/periods`, { as: esi });
    const withoutFirstMaths = cur.body.items
      .filter((p: any) => !(p.subject === 'Maths' && p.weekday === 1))
      .map((p: any) => ({ subject: p.subject, teacher_id: p.teacher.id, weekday: p.weekday, starts_at: p.starts_at, ends_at: p.ends_at }));
    const r = await h.call('PUT', `/class_sections/${id('sec:6A')}/periods`, { as: esi, json: withoutFirstMaths });
    assert.equal(r.status, 409);
    assert.equal(r.body.code, 'period_in_use');
  });
});

describe('enrollments', () => {
  test('enrol, withdraw (soft), re-enrol; duplicates are a clear 409', async () => {
    const esi = await h.login('esi');
    const made = await h.call('POST', '/enrollments', { as: esi, json: { student_id: id('p:ama'), class_section_id: id('sec:6B') } });
    assert.equal(made.status, 201);
    assert.equal(made.body.status, 'active');
    const dup = await h.call('POST', '/enrollments', { as: esi, json: { student_id: id('p:ama'), class_section_id: id('sec:6B') } });
    assert.equal(dup.status, 409);
    assert.equal(dup.body.code, 'already_enrolled');

    assert.equal((await h.call('DELETE', `/enrollments/${made.body.id}`, { as: esi })).status, 204);
    const row = await h.db.asService((tx) => tx.query(`select status from enrollments where id = $1`, [made.body.id]));
    assert.equal(row.rows[0]!.status, 'withdrawn'); // history kept, never deleted

    const again = await h.call('POST', '/enrollments', { as: esi, json: { student_id: id('p:ama'), class_section_id: id('sec:6B') } });
    assert.equal(again.status, 201);
    assert.equal(again.body.id, made.body.id);
    await h.call('DELETE', `/enrollments/${made.body.id}`, { as: esi });
  });

  test('only admin enrols; a non-student cannot be enrolled', async () => {
    assert.equal((await h.call('POST', '/enrollments', { as: await h.login('kwame'), json: { student_id: id('p:ama'), class_section_id: id('sec:6A') } })).status, 403);
    const r = await h.call('POST', '/enrollments', { as: await h.login('esi'), json: { student_id: id('p:akua'), class_section_id: id('sec:6A') } });
    assert.equal(r.status, 422);
  });
});

describe('bulk student import', () => {
  test('admin creates and enrols a batch of new students in one call', async () => {
    const as = await h.login('esi');
    const before = await h.call('GET', `/class_sections/${id('sec:6B')}`, { as });
    const r = await h.call('POST', `/class_sections/${id('sec:6B')}/students/import`, {
      as, json: { students: [{ full_name: 'Abena New' }, { full_name: 'Yaw New' }] },
    });
    assert.equal(r.status, 201);
    assert.deepEqual(r.body.items.map((s: any) => s.full_name), ['Abena New', 'Yaw New']);
    const after = await h.call('GET', `/class_sections/${id('sec:6B')}`, { as });
    assert.equal(after.body.roster.length, before.body.roster.length + 2);

    // each is a real, independently fetchable student, enrolled in 6B
    for (const s of r.body.items) {
      const profile = await h.call('GET', `/students/${s.id}`, { as });
      assert.equal(profile.status, 200);
      assert.equal(profile.body.class_section.name, '6B');
    }

    await h.db.asService((tx) =>
      tx.query(`delete from enrollments where student_id = any($1::uuid[])`, [r.body.items.map((s: any) => s.id)]),
    );
    await h.db.asService((tx) => tx.query(`delete from people where id = any($1::uuid[])`, [r.body.items.map((s: any) => s.id)]));
  });

  test('only admin imports; an empty batch or a blank name is rejected', async () => {
    assert.equal(
      (await h.call('POST', `/class_sections/${id('sec:6B')}/students/import`, { as: await h.login('kwame'), json: { students: [{ full_name: 'X' }] } })).status,
      403,
    );
    const as = await h.login('esi');
    assert.equal((await h.call('POST', `/class_sections/${id('sec:6B')}/students/import`, { as, json: { students: [] } })).status, 400);
    assert.equal((await h.call('POST', `/class_sections/${id('sec:6B')}/students/import`, { as, json: { students: [{ full_name: '  ' }] } })).status, 400);
  });

  test('a section id from another school is an invalid reference, not a leaked 500', async () => {
    const r = await h.call('POST', `/class_sections/${id('sec:rb:1')}/students/import`, {
      as: await h.login('esi'), json: { students: [{ full_name: 'Ghost Student' }] },
    });
    assert.equal(r.status, 409);
    assert.equal(r.body.code, 'invalid_reference');
    // the transaction rolled back whole: no orphaned person row left behind
    const orphan = await h.db.asService((tx) => tx.query(`select 1 from people where full_name = 'Ghost Student'`));
    assert.equal(orphan.rowCount, 0);
  });
});
