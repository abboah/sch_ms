import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => { h = await setup(); });
after(async () => { await h.close(); });

describe('extras the screens rely on', () => {
  test('/me carries the current term for the header', async () => {
    const r = await h.call('GET', '/me', { as: await h.login('akua') });
    assert.deepEqual([r.body.school.term.name, r.body.school.term.starts_on, r.body.school.term.ends_on], ['Term 1 2026', '2026-09-07', '2026-12-18']);
  });

  test('the admin student list names each pupil\'s guardians, primary first; teachers do not get them', async () => {
    const admin = await h.call('GET', '/students?q=kofi', { as: await h.login('esi') });
    assert.deepEqual(admin.body.items[0].guardian_names, ['Akua Asante', 'Kwabena Asante']);
    const teacher = await h.call('GET', '/students?q=kofi', { as: await h.login('kwame') });
    assert.equal(teacher.body.items[0].guardian_names, undefined);
  });

  test('a teacher sees a pupil\'s guardians by name only, so they can start a conversation; admin also gets contacts', async () => {
    const t = await h.call('GET', `/students/${id('p:kofi')}`, { as: await h.login('kwame') });
    assert.deepEqual(t.body.guardians.map((g: any) => g.guardian.full_name).sort(), ['Akua Asante', 'Kwabena Asante']);
    assert.ok(t.body.guardians.every((g: any) => g.guardian.contact === undefined), 'no phone numbers for teachers');
    assert.equal(t.body.enrollments, undefined);
    const a = await h.call('GET', `/students/${id('p:kofi')}`, { as: await h.login('esi') });
    assert.ok(a.body.guardians.every((g: any) => g.guardian.contact));
  });

  test('enrollment history names the section and term, newest term first', async () => {
    const r = await h.call('GET', `/students/${id('p:kofi')}`, { as: await h.login('esi') });
    assert.deepEqual(r.body.enrollments.map((e: any) => [e.class_section_name, e.term_name, e.status]), [
      ['6A', 'Term 1 2026', 'active'], ['5A', 'Term 2 2025', 'completed'],
    ]);
  });

  test('the staff directory says what each teacher teaches this term', async () => {
    const r = await h.call('GET', '/people?role=teacher', { as: await h.login('esi') });
    const yaw = r.body.items.find((p: any) => p.full_name === 'Yaw Darko');
    assert.deepEqual(yaw.assignments.map((a: any) => `${a.class_section.name}:${a.subject}`), ['6A:Science', '6B:Science']);
    const kwame = r.body.items.find((p: any) => p.full_name === 'Kwame Boateng');
    assert.deepEqual(kwame.assignments.map((a: any) => a.subject), ['Homeroom', 'Maths'], 'the closed-term 5A is not listed');
    assert.equal(r.body.items.find((p: any) => p.full_name === 'Comfort Sefa').assignments[0].class_section.name, '4B');
  });

  test('the payments ledger shows who and what each payment is for', async () => {
    const r = await h.call('GET', '/payments', { as: await h.login('esi') });
    const kofi = r.body.items.find((p: any) => p.student.full_name === 'Kofi Asante');
    assert.deepEqual([kofi.description, kofi.amount, kofi.status], ['Tuition', '1250.00', 'succeeded']);
    assert.ok(r.body.items.every((p: any) => p.created_at));
  });

  test('audit entries name the pupil whose record was read', async () => {
    await h.call('GET', `/students/${id('p:yaa')}`, { as: await h.login('nana') });
    const r = await h.call('GET', '/audit_log?limit=1', { as: await h.login('esi') });
    assert.equal(r.body.items[0].student.full_name, 'Yaa Adjei');
  });
});

describe('sandbox checkout (development only)', () => {
  test('completing a sandbox payment runs the whole real path: webhook, settlement, receipt', async () => {
    const as = await h.login('akua');
    const start = await h.call('POST', `/invoices/${id('inv:kofi')}/pay`, { as, json: { amount: '100.00', method: 'card' } });
    const ref = start.body.payment.provider_ref;

    const done = await h.call('POST', '/dev/sandbox/complete', { json: { reference: ref, outcome: 'succeeded' } });
    assert.equal(done.status, 204);
    const p = await h.call('GET', `/payments/${start.body.payment.id}`, { as });
    assert.equal(p.body.status, 'succeeded');
    const inv = await h.call('GET', `/students/${id('p:kofi')}/invoices`, { as });
    assert.equal(inv.body.items[0].outstanding, '500.00');
    const log = await h.db.asService((tx) => tx.query(`select outcome from webhook_events where provider_ref = $1`, [ref]));
    assert.deepEqual(log.rows.map((x: any) => x.outcome), ['processed']);
  });

  test('a failed outcome and an unknown reference', async () => {
    const as = await h.login('akua');
    const start = await h.call('POST', `/invoices/${id('inv:kofi')}/pay`, { as, json: { amount: '50.00', method: 'mtn_momo' } });
    await h.call('POST', '/dev/sandbox/complete', { json: { reference: start.body.payment.provider_ref, outcome: 'failed' } });
    assert.equal((await h.call('GET', `/payments/${start.body.payment.id}`, { as })).body.status, 'failed');
    assert.equal((await h.call('POST', '/dev/sandbox/complete', { json: { reference: 'HR-nope', outcome: 'succeeded' } })).status, 404);
  });
});
