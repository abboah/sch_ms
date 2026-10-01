import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { EMAILS, PASSWORD, id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => { h = await setup(); });
after(async () => { await h.close(); });

const tokenFromEmail = () => /token=([\w-]+)/.exec(h.email.sent.at(-1)?.text ?? '')?.[1] ?? '';

describe('people directory', () => {
  test('admin lists guardians and staff with contact details; others are refused', async () => {
    const as = await h.login('esi');
    const g = await h.call('GET', '/people?role=guardian', { as });
    assert.deepEqual(g.body.items.map((p: any) => p.full_name), ['Akua Asante', 'Efua Quaye', 'Kwabena Asante', 'Nana Adjei', 'Samuel Tetteh']);
    assert.equal(g.body.items[0].contact.phone, '+233240000001');
    const q = await h.call('GET', '/people?q=owusu', { as });
    assert.deepEqual(q.body.items.map((p: any) => p.full_name), ['Abena Owusu']);
    const all = await h.call('GET', '/people?limit=4', { as });
    assert.equal(all.body.items.length, 4);
    assert.ok(all.body.next_cursor);
    assert.ok(!all.body.items.some((p: any) => p.role === 'student'));
    assert.equal((await h.call('GET', '/people', { as: await h.login('akua') })).status, 403);
  });

  test('a parent cannot read another person\'s phone or email, even their child\'s teacher\'s', async () => {
    const r = await h.db.asUser(id('p:akua'), (tx) => tx.query('select person_id from person_contacts'));
    assert.deepEqual(r.rows.map((x: any) => x.person_id), [id('p:akua')], 'only her own contact row is visible');
    const teacher = await h.db.asUser(id('p:akua'), (tx) => tx.query('select 1 from people where id = $1', [id('p:kwame')]));
    assert.equal(teacher.rowCount, 1, 'she can see her child\'s teacher exists');
    const contact = await h.db.asUser(id('p:akua'), (tx) => tx.query('select 1 from person_contacts where person_id = $1', [id('p:kwame')]));
    assert.equal(contact.rowCount, 0, 'but not how to reach them');
  });
});

describe('creating people and inviting them', () => {
  test('a guardian invited by phone can sign in by SMS code straight away', async () => {
    const as = await h.login('esi');
    h.sms.clear();
    const made = await h.call('POST', '/people', { as, json: { full_name: 'Yaw Mensah', role: 'guardian', phone: '020 555 0199', invite: true } });
    assert.equal(made.status, 201);
    assert.equal(made.body.contact.phone, '+233205550199');
    assert.match(h.sms.sent[0]!.text, /Homeroom/);

    h.sms.clear();
    await h.call('POST', '/auth/otp', { json: { phone: '0205550199' } });
    const code = /(\d{6})/.exec(h.sms.sent[0]!.text)![1];
    const session = await h.call('POST', '/auth/otp/verify', { json: { phone: '0205550199', code } });
    assert.equal(session.status, 200);
    assert.equal(session.body.session.me.full_name, 'Yaw Mensah');
    assert.deepEqual(session.body.session.me.children, []);
  });

  test('staff invited by email choose a password from the link; the link works once', async () => {
    const as = await h.login('esi');
    h.email.clear();
    const made = await h.call('POST', '/people', { as, json: { full_name: 'Ama Boakye', role: 'teacher', email: 'Ama.Boakye@greenfield.edu.gh', invite: true } });
    assert.equal(made.status, 201);
    assert.equal(h.email.sent[0]!.to, 'ama.boakye@greenfield.edu.gh');
    const token = tokenFromEmail();

    const cantYet = await h.call('POST', '/auth/sessions', { json: { email: 'ama.boakye@greenfield.edu.gh', password: 'anything' } });
    assert.equal(cantYet.status, 401, 'no password exists until they choose one');

    assert.equal((await h.call('POST', '/auth/password/reset', { json: { token, new_password: 'short' } })).status, 400);
    assert.equal((await h.call('POST', '/auth/password/reset', { json: { token, new_password: 'a long enough password' } })).status, 204);
    const again = await h.call('POST', '/auth/password/reset', { json: { token, new_password: 'another long password' } });
    assert.equal(again.status, 400);
    assert.equal(again.body.code, 'invalid_reset_token');

    const session = await h.call('POST', '/auth/sessions', { json: { email: 'ama.boakye@greenfield.edu.gh', password: 'a long enough password' } });
    assert.equal(session.body.session.me.role, 'teacher');
  });

  test('an email that already has an account links the new role to it: one sign-in, then a choice', async () => {
    const as = await h.login('esi');
    const made = await h.call('POST', '/people', { as, json: { full_name: 'Esi Mensah', role: 'guardian', email: EMAILS.esi, invite: true } });
    assert.equal(made.status, 201);
    const r = await h.call('POST', '/auth/sessions', { json: { email: EMAILS.esi, password: PASSWORD } });
    assert.equal(r.body.status, 'selection_required');
    assert.deepEqual(r.body.selection.choices.map((c: any) => c.role).sort(), ['admin', 'guardian']);
    // restore the demo world for any test after this one
    await h.db.asService(async (tx) => {
      await tx.query(`delete from person_contacts where person_id = $1`, [made.body.id]);
      await tx.query(`delete from people where id = $1`, [made.body.id]);
    });
  });

  test('only admin creates people; role must be valid; a student gets no login', async () => {
    assert.equal((await h.call('POST', '/people', { as: await h.login('kwame'), json: { full_name: 'X', role: 'guardian' } })).status, 403);
    assert.equal((await h.call('POST', '/people', { as: await h.login('esi'), json: { full_name: 'X', role: 'wizard' } })).status, 400);
    h.email.clear(); h.sms.clear();
    const kid = await h.call('POST', '/people', { as: await h.login('esi'), json: { full_name: 'New Pupil', role: 'student', email: 'kid@example.com', invite: true } });
    assert.equal(kid.status, 201);
    assert.equal(h.email.sent.length + h.sms.sent.length, 0);
  });
});

describe('password reset', () => {
  test('a reset link is emailed for a real account, nothing is sent for an unknown one, and both answer 204', async () => {
    h.email.clear();
    assert.equal((await h.call('POST', '/auth/password/forgot', { json: { email: EMAILS.nana } })).status, 204);
    assert.equal(h.email.sent.length, 1);
    assert.equal((await h.call('POST', '/auth/password/forgot', { json: { email: 'ghost@example.com' } })).status, 204);
    assert.equal(h.email.sent.length, 1);
  });

  test('choosing a new password signs the account out everywhere and the old password stops working', async () => {
    const before = await h.call('POST', '/auth/sessions', { json: { email: EMAILS.efua, password: PASSWORD } });
    h.email.clear();
    await h.call('POST', '/auth/password/forgot', { json: { email: EMAILS.efua } });
    await h.call('POST', '/auth/password/reset', { json: { token: tokenFromEmail(), new_password: 'brand new password' } });
    assert.equal((await h.call('POST', '/auth/refresh', { json: { refresh_token: before.body.session.refresh_token } })).status, 401);
    assert.equal((await h.call('POST', '/auth/sessions', { json: { email: EMAILS.efua, password: PASSWORD } })).status, 401);
    assert.equal((await h.call('POST', '/auth/sessions', { json: { email: EMAILS.efua, password: 'brand new password' } })).status, 200);
  });

  test('an expired link is refused', async () => {
    h.email.clear();
    await h.call('POST', '/auth/password/forgot', { json: { email: EMAILS.samuel } });
    const token = tokenFromEmail();
    h.clock.advance(61 * 60 * 1000);
    assert.equal((await h.call('POST', '/auth/password/reset', { json: { token, new_password: 'a long enough password' } })).status, 400);
    h.clock.advance(-61 * 60 * 1000);
  });
});

describe('guardian links', () => {
  test('admin links a guardian to a pupil; the guardian immediately sees them; roles are checked', async () => {
    const as = await h.login('esi');
    const nana = await h.login('nana');
    assert.equal((await h.call('GET', '/students', { as: nana })).body.items.length, 1);
    const linked = await h.call('PUT', `/students/${id('p:kweku')}/guardians`, { as, json: { guardian_id: id('p:nana'), relationship: 'aunt' } });
    assert.equal(linked.status, 204);
    const kids = await h.call('GET', '/students', { as: nana });
    assert.deepEqual(kids.body.items.map((s: any) => s.full_name), ['Kweku Sarpong', 'Yaa Adjei']);

    await h.call('PUT', `/students/${id('p:kweku')}/guardians`, { as, json: { guardian_id: id('p:nana'), relationship: 'godmother', is_primary_contact: true } });
    const detail = await h.call('GET', `/students/${id('p:kweku')}`, { as });
    assert.deepEqual([detail.body.guardians[0].relationship, detail.body.guardians[0].is_primary_contact], ['godmother', true]);

    const notGuardian = await h.call('PUT', `/students/${id('p:kweku')}/guardians`, { as, json: { guardian_id: id('p:kwame') } });
    assert.equal(notGuardian.status, 422);
    assert.equal((await h.call('PUT', `/students/${id('p:akua')}/guardians`, { as, json: { guardian_id: id('p:nana') } })).status, 404);
    assert.equal((await h.call('PUT', `/students/${id('p:kweku')}/guardians`, { as: await h.login('kwame'), json: { guardian_id: id('p:nana') } })).status, 403);
  });
});

describe('audit log', () => {
  test('who looked at a child\'s record is visible to admin, filterable and pageable; nobody else can read it', async () => {
    await h.call('GET', `/students/${id('p:kofi')}`, { as: await h.login('akua') });
    await h.call('GET', `/students/${id('p:kofi')}/summary`, { as: await h.login('kwame') });
    await h.call('GET', `/students/${id('p:kofi')}/grades`, { as: await h.login('kwabena') });

    const as = await h.login('esi');
    const all = await h.call('GET', `/audit_log?student_id=${id('p:kofi')}`, { as });
    assert.deepEqual(all.body.items.map((e: any) => e.actor.full_name), ['Kwabena Asante', 'Kwame Boateng', 'Akua Asante']);
    assert.ok(all.body.items.every((e: any) => e.action === 'read'));
    const page1 = await h.call('GET', `/audit_log?student_id=${id('p:kofi')}&limit=2`, { as });
    assert.equal(page1.body.items.length, 2);
    const page2 = await h.call('GET', `/audit_log?student_id=${id('p:kofi')}&limit=2&cursor=${page1.body.next_cursor}`, { as });
    assert.deepEqual(page2.body.items.map((e: any) => e.actor.full_name), ['Akua Asante']);
    assert.equal(page2.body.next_cursor, null);
    const byActor = await h.call('GET', `/audit_log?actor_id=${id('p:kwame')}`, { as });
    assert.ok(byActor.body.items.every((e: any) => e.actor.full_name === 'Kwame Boateng'));

    assert.equal((await h.call('GET', '/audit_log', { as: await h.login('akua') })).status, 403);
    assert.equal((await h.call('GET', '/audit_log', { as: await h.login('kwame') })).status, 403);
  });

  test('a refused read leaves no trace (a stranger probing a child\'s id is not logged as a viewer)', async () => {
    const before = await h.db.asService((tx) => tx.query(`select count(*)::int n from audit_log where actor_id = $1`, [id('p:samuel')]));
    await h.call('GET', `/students/${id('p:kofi')}`, { as: await h.login('samuel') });
    const after = await h.db.asService((tx) => tx.query(`select count(*)::int n from audit_log where actor_id = $1`, [id('p:samuel')]));
    assert.equal(after.rows[0]!.n, before.rows[0]!.n);
  });
});
