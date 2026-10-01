import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { enqueueFeesDueSoon, processOutbox } from '../src/jobs/outbox.ts';
import { id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => { h = await setup(); });
after(async () => { await h.close(); });

const drain = () => processOutbox(h.deps);
const quiet = () => { h.sms.clear(); h.push.clear(); h.email.clear(); };
const markKofi = async (status: string, date = '2026-10-05') =>
  h.call('PUT', `/class_sections/${id('sec:6A')}/attendance`, {
    as: await h.login('kwame'),
    json: { date, period_id: id('per:6A:maths:1'), entries: [{ student_id: id('p:kofi'), status, marked_at: '2026-10-05T07:50:00Z' }] },
  });
const deliveries = (who: string, channel: string) =>
  h.db.asService((tx) =>
    tx.query(
      `select d.status, d.detail from notification_deliveries d join notifications n on n.id = d.notification_id
        where n.person_id = $1 and d.channel = $2 order by d.id`,
      [id(who), channel],
    ),
  );

describe('the seeded world is delivered', () => {
  test('draining the outbox fills the parents\' inboxes; draining again does nothing', async () => {
    const first = await drain();
    assert.ok(first.processed >= 8, `processed ${first.processed}`);
    assert.equal(first.failed, 0);
    assert.equal((await drain()).processed, 0);
    const inbox = await h.call('GET', '/notifications', { as: await h.login('akua') });
    const kinds = new Set(inbox.body.items.map((n: any) => n.kind));
    for (const k of ['payment.succeeded', 'announcement.published', 'message.sent', 'homework.posted', 'attendance.marked']) {
      assert.ok(kinds.has(k), `Akua should have a ${k} notification`);
    }
    assert.equal(inbox.body.unread_count, inbox.body.items.length);
  });

  test('the inbox pages, marks some read, then all', async () => {
    const as = await h.login('akua');
    const total = (await h.call('GET', '/notifications', { as })).body.unread_count;
    const p1 = await h.call('GET', '/notifications?limit=2', { as });
    assert.equal(p1.body.items.length, 2);
    const p2 = await h.call('GET', `/notifications?limit=2&cursor=${p1.body.next_cursor}`, { as });
    assert.ok(p2.body.items.every((n: any) => !p1.body.items.some((m: any) => m.id === n.id)));
    await h.call('POST', '/notifications/read', { as, json: { ids: [p1.body.items[0].id] } });
    assert.equal((await h.call('GET', '/notifications', { as })).body.unread_count, total - 1);
    assert.equal((await h.call('GET', '/notifications?unread=true&limit=200', { as })).body.items.length, total - 1);
    await h.call('POST', '/notifications/read', { as, json: {} });
    assert.equal((await h.call('GET', '/notifications', { as })).body.unread_count, 0);
  });

  test('nobody can read or mark another person\'s notifications', async () => {
    const akuaItems = (await h.call('GET', '/notifications?limit=1', { as: await h.login('akua') })).body.items;
    const samuel = await h.login('samuel');
    await h.call('POST', '/notifications/read', { as: samuel, json: { ids: [akuaItems[0].id] } });
    const row = await h.db.asService((tx) => tx.query(`select read_at from notifications where id = $1`, [akuaItems[0].id]));
    assert.ok(row.rows[0]!.read_at, 'still Akua\'s own read state, untouched by Samuel');
    const samuelInbox = await h.call('GET', '/notifications?limit=200', { as: samuel });
    assert.ok(!samuelInbox.body.items.some((n: any) => n.id === akuaItems[0].id));
  });
});

describe('channels: push first, SMS as the fallback', () => {
  test('an absence pushes to the parent with the app and texts the parent without it', async () => {
    quiet();
    await markKofi('absent');
    await drain();
    assert.equal(h.push.sent.length, 1);
    assert.deepEqual(h.push.sent[0]!.targets.map((t) => t.token), ['fcm-token-akua-1']);
    assert.equal(h.push.sent[0]!.message.title, 'Marked absent');
    assert.match(h.push.sent[0]!.message.body, /Kofi Asante was marked absent on .*5 Oct \(Maths\)/);
    assert.deepEqual(h.sms.sent.map((s) => s.to), ['+233240000002'], 'Kwabena has no device, so he gets the text');
    assert.match(h.sms.sent[0]!.text, /^Marked absent: Kofi Asante/);
  });

  test('a parent who turned SMS off is skipped, and the skip is recorded', async () => {
    await h.call('PUT', '/me/notification_prefs', { as: await h.login('kwabena'), json: { push: true, email: true, sms: false } });
    quiet();
    await markKofi('late');
    await drain();
    assert.equal(h.sms.sent.length, 0);
    const d = await deliveries('p:kwabena', 'sms');
    assert.equal(d.rows.at(-1)!.status, 'skipped');
    assert.match(d.rows.at(-1)!.detail, /turned off/);
  });

  test('push that throws falls back to SMS instead of failing the event', async () => {
    const real = h.deps.push.send;
    h.deps.push.send = async () => { throw new Error('FCM 503'); };
    quiet();
    await markKofi('absent', '2026-10-06');
    const r = await drain();
    h.deps.push.send = real;
    assert.equal(r.failed, 0);
    assert.ok(h.sms.sent.some((s) => s.to === '+233240000001'), 'Akua falls back to SMS');
    const d = await deliveries('p:akua', 'push');
    assert.equal(d.rows.at(-1)!.status, 'failed');
  });

  test('tokens the provider reports as dead are removed', async () => {
    const real = h.deps.push.send;
    h.deps.push.send = async () => ({ invalidTokens: ['fcm-token-akua-1'] });
    await markKofi('absent', '2026-10-07');
    await drain();
    h.deps.push.send = real;
    const left = await h.db.asService((tx) => tx.query(`select count(*)::int n from push_tokens where token = 'fcm-token-akua-1'`));
    assert.equal(left.rows[0]!.n, 0);
  });

  test('re-registering a device brings push back', async () => {
    const r = await h.call('POST', '/me/push_tokens', { as: await h.login('akua'), json: { token: 'fcm-token-akua-2', platform: 'ios' } });
    assert.equal(r.status, 204);
    quiet();
    await markKofi('absent', '2026-10-08');
    await drain();
    assert.deepEqual(h.push.sent[0]!.targets.map((t) => t.token), ['fcm-token-akua-2']);
    assert.equal((await h.call('DELETE', '/me/push_tokens/fcm-token-akua-2', { as: await h.login('akua') })).status, 204);
  });
});

describe('what triggers what', () => {
  test('a message notifies the other person only', async () => {
    quiet();
    await h.call('POST', `/threads/${id('thr:kofi')}/messages`, { as: await h.login('kwame'), json: { body: 'Kofi did well today.' } });
    await drain();
    const akua = await h.call('GET', '/notifications?limit=200', { as: await h.login('akua') });
    const got = akua.body.items.find((n: any) => n.kind === 'message.sent' && /Kofi did well/.test(n.body));
    assert.equal(got.title, 'New message about Kofi Asante');
    assert.match(got.body, /^Kwame Boateng: Kofi did well/);
    const kwame = await h.call('GET', '/notifications?limit=50', { as: await h.login('kwame') });
    assert.ok(!kwame.body.items.some((n: any) => n.kind === 'message.sent' && /Kofi did well/.test(n.body)));
  });

  test('a school-wide notice reaches every guardian; a class notice only that class\'s parents', async () => {
    const esi = await h.login('esi');
    const wide = await h.call('POST', '/announcements', { as: esi, json: { title: 'Sports day', body: 'Friday 16 Oct.', published: true } });
    const cls = await h.call('POST', '/announcements', { as: await h.login('kwame'), json: { title: 'Maths quiz', body: 'Bring a calculator.', class_section_id: id('sec:6A'), published: true } });
    await drain();
    const count = async (annId: string) =>
      (await h.db.asService((tx) => tx.query(`select count(*)::int n from notifications where data->>'announcement_id' = $1`, [annId]))).rows[0]!.n;
    assert.equal(await count(wide.body.id), 5);
    assert.equal(await count(cls.body.id), 3); // Akua + Kwabena (Kofi), Nana (Yaa)
  });

  test('a settled payment sends a receipt by push, SMS fallback and email', async () => {
    const start = await h.call('POST', `/invoices/${id('inv:kofi')}/pay`, { as: await h.login('akua'), json: { amount: '600.00', method: 'card' } });
    const signed = h.payments.sign({ event: 'payment.succeeded', reference: start.body.payment.provider_ref, amount: '600.00', method: 'card', metadata: { invoice_id: id('inv:kofi') } });
    quiet();
    await h.call('POST', '/webhooks/payment', { raw: signed.body, headers: signed.headers });
    await drain();
    assert.ok(h.email.sent.some((e) => e.to === 'akua.asante@greenfield.edu.gh' && /GH¢600\.00 received for Kofi Asante/.test(e.text)));
    assert.ok(h.email.sent.some((e) => e.to === 'kwabena.asante@greenfield.edu.gh'));
  });

  test('a homework post reaches the class\'s parents by push only (no SMS for homework)', async () => {
    quiet();
    await h.call('POST', `/class_sections/${id('sec:6A')}/homework`, { as: await h.login('kwame'), json: { title: 'Times tables', due_date: '2026-10-09' } });
    await drain();
    assert.equal(h.sms.sent.length, 0);
    const n = await h.db.asService((tx) => tx.query(`select count(*)::int n from notifications where kind = 'homework.posted' and title = 'New homework: Times tables'`));
    assert.equal(n.rows[0]!.n, 3);
  });
});

describe('reliability', () => {
  test('a poison event is retried with growing delay, parked after five attempts, and never blocks the rest', async () => {
    // A message event whose school does not exist violates a foreign key when its notification is stored.
    const msg = await h.db.asService((tx) => tx.query(`select id from messages limit 1`));
    const poison = await h.db.asService((tx) =>
      tx.query(
        `insert into notification_outbox (school_id, kind, ref_id, payload) values ($1, 'message.sent', $2, $3) returning id`,
        [id('school:nowhere'), msg.rows[0]!.id, JSON.stringify({ sender_id: id('p:akua'), thread_id: id('thr:kofi') })],
      ),
    );
    const good = await h.db.asService((tx) =>
      tx.query(`insert into notification_outbox (school_id, kind, payload) values ($1, 'unknown.kind', '{}') returning id`, [id('school:greenfield')]),
    );

    const first = await drain();
    assert.equal(first.failed, 1);
    assert.ok(first.processed >= 1, 'the healthy event after it still went through');
    const row = async () => (await h.db.asService((tx) => tx.query(`select status, attempts, last_error, run_after from notification_outbox where id = $1`, [poison.rows[0]!.id]))).rows[0]!;
    let r = await row();
    assert.deepEqual([r.status, r.attempts], ['pending', 1]);
    assert.ok(r.last_error);
    assert.equal((await drain()).failed, 0, 'not retried before its backoff has passed');

    const delays: number[] = [];
    for (let attempt = 2; attempt <= 5; attempt++) {
      h.clock.advance(2 * 60 * 60 * 1000);
      await drain();
      const next = await row();
      delays.push(new Date(next.run_after).getTime() - h.clock.now().getTime());
      r = next;
    }
    assert.deepEqual([r.status, r.attempts], ['failed', 5]);
    assert.ok(delays[1]! > delays[0]!, 'the delay grows between attempts');
    const ok = await h.db.asService((tx) => tx.query(`select status from notification_outbox where id = $1`, [good.rows[0]!.id]));
    assert.equal(ok.rows[0]!.status, 'done');
    h.clock.advance(-8 * 60 * 60 * 1000);
  });

  test('fee reminders: queued once per invoice for bills due within three days, never for paid or past-due ones', async () => {
    h.clock.set('2026-10-13T08:00:00Z');
    assert.equal(await enqueueFeesDueSoon(h.deps), 2); // Yaa and Kojo, due 15 Oct
    assert.equal(await enqueueFeesDueSoon(h.deps), 0, 'idempotent');
    quiet();
    await drain();
    const nana = await h.call('GET', '/notifications?limit=5', { as: await h.login('nana') });
    const due = nana.body.items.find((n: any) => n.kind === 'fees.due_soon');
    assert.equal(due.title, 'Fees due soon');
    assert.match(due.body, /GH¢1,850\.00 for Yaa Adjei's Tuition is due .*15 Oct/);
    assert.ok(h.sms.sent.some((s) => s.to === '+233240000003'), 'Nana has no app, so she is texted');
    h.clock.set('2026-10-05T08:00:00Z');
  });
});
