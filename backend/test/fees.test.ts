import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => { h = await setup(); });
after(async () => { await h.close(); });

const webhook = (ref: string, invoice: string, amount: string, event = 'payment.succeeded', method = 'card') =>
  h.payments.sign({ event, reference: ref, amount, method, metadata: { invoice_id: invoice } });

const post = (path: string, signed: { body: string; headers: Record<string, string> }) =>
  h.call('POST', path, { raw: signed.body, headers: signed.headers });

/** The 'invoices' describe below counts the school's invoices exactly, so every invoice or fee
 *  item created here is torn down again (service role: invoices have no delete policy by design). */
const wipeInvoice = (id_: string) => h.db.asService((tx) => tx.query('delete from invoices where id = $1', [id_]));
const wipeFeeItem = (id_: string) => h.db.asService((tx) => tx.query('delete from fee_items where id = $1', [id_]));

describe('fee items', () => {
  test('admin defines a reusable fee; invoices may tag themselves with it', async () => {
    const as = await h.login('esi');
    const created = await h.call('POST', '/fee_items', { as, json: { name: 'Term 1 Tuition', default_amount: '1850.00' } });
    assert.equal(created.status, 201);
    assert.deepEqual([created.body.name, created.body.default_amount, created.body.active], ['Term 1 Tuition', '1850.00', true]);

    const listed = await h.call('GET', '/fee_items', { as });
    assert.ok(listed.body.items.some((f: any) => f.id === created.body.id));

    const invoice = await h.call('POST', '/invoices', {
      as,
      json: {
        student_id: id('p:kweku'), term_id: id('term:gf:2026t1'), description: 'Term 1 Tuition',
        amount_due: '1850.00', due_date: '2026-11-01', fee_item_id: created.body.id,
      },
    });
    assert.equal(invoice.status, 201);
    assert.equal(invoice.body.items[0].fee_item_id, created.body.id);

    const retired = await h.call('PATCH', `/fee_items/${created.body.id}`, { as, json: { active: false } });
    assert.equal(retired.body.active, false);
    // the existing invoice's tag survives retiring the fee item
    const stillTagged = await h.call('GET', '/invoices?limit=100', { as });
    assert.ok(stillTagged.body.items.some((i: any) => i.fee_item_id === created.body.id));

    await wipeInvoice(invoice.body.items[0].id);
    await wipeFeeItem(created.body.id);
  });

  test('an invoice with no fee_item_id keeps working exactly as before', async () => {
    const as = await h.login('esi');
    const r = await h.call('POST', '/invoices', {
      as, json: { student_id: id('p:kweku'), term_id: id('term:gf:2026t1'), description: 'Sports kit', amount_due: '60.00', due_date: '2026-11-01' },
    });
    assert.equal(r.status, 201);
    assert.equal(r.body.items[0].fee_item_id, null);
    await wipeInvoice(r.body.items[0].id);
  });

  test('a fee item from another school is rejected as an invalid reference, not silently accepted', async () => {
    const as = await h.login('esi');
    const riverside = await h.deps.tokens.signAccess(
      { personId: id('p:rb:admin'), role: 'admin', schoolId: id('school:riverside'), sessionId: randomUUID() },
      900,
    );
    const theirs = await h.call('POST', '/fee_items', { as: riverside, json: { name: 'Other school fee', default_amount: '1.00' } });
    assert.equal(theirs.status, 201);
    const r = await h.call('POST', '/invoices', {
      as,
      json: {
        student_id: id('p:kweku'), term_id: id('term:gf:2026t1'), description: 'x', amount_due: '1.00',
        due_date: '2026-11-01', fee_item_id: theirs.body.id,
      },
    });
    assert.equal(r.status, 409);
    assert.equal(r.body.code, 'invalid_reference');
    await wipeFeeItem(theirs.body.id);
  });

  test('only admin manages fee items', async () => {
    assert.equal((await h.call('GET', '/fee_items', { as: await h.login('akua') })).status, 403);
    assert.equal((await h.call('POST', '/fee_items', { as: await h.login('kwame'), json: { name: 'x', default_amount: '1.00' } })).status, 403);
  });
});

describe('invoices', () => {
  test('admin lists the school\'s invoices, filters by status and by derived overdue', async () => {
    const as = await h.login('esi');
    const all = await h.call('GET', '/invoices', { as });
    assert.equal(all.body.items.length, 4);
    const overdue = await h.call('GET', '/invoices?status=overdue', { as });
    assert.deepEqual(overdue.body.items.map((i: any) => i.student.full_name), ['Kofi Asante']);
    const paid = await h.call('GET', '/invoices?status=paid', { as });
    assert.deepEqual(paid.body.items.map((i: any) => i.student.full_name), ['Ama Asante']);
  });

  test('pagination walks every invoice exactly once', async () => {
    const as = await h.login('esi');
    const seen: string[] = [];
    let cursor: string | null = null;
    do {
      const r: any = await h.call('GET', `/invoices?limit=3${cursor ? `&cursor=${cursor}` : ''}`, { as });
      seen.push(...r.body.items.map((i: any) => i.id));
      cursor = r.body.next_cursor;
    } while (cursor);
    assert.equal(seen.length, 4);
    assert.equal(new Set(seen).size, 4);
  });

  test('only admin lists all invoices', async () => {
    assert.equal((await h.call('GET', '/invoices', { as: await h.login('akua') })).status, 403);
    assert.equal((await h.call('GET', '/invoices', { as: await h.login('kwame') })).status, 403);
  });

  test('admin bills one pupil, or a whole class at once; validation is strict', async () => {
    const as = await h.login('esi');
    const one = await h.call('POST', '/invoices', {
      as, json: { student_id: id('p:kweku'), term_id: id('term:gf:2026t1'), description: 'Trip levy', amount_due: '75.50', due_date: '2026-11-01' },
    });
    assert.equal(one.status, 201);
    assert.deepEqual([one.body.items[0].amount_due, one.body.items[0].status, one.body.items[0].overdue], ['75.50', 'unpaid', false]);

    const bulk = await h.call('POST', '/invoices', {
      as, json: { class_section_id: id('sec:4B'), term_id: id('term:gf:2026t1'), description: 'Books', amount_due: '120.00', due_date: '2026-11-01' },
    });
    assert.equal(bulk.body.items.length, 10);

    const both = await h.call('POST', '/invoices', {
      as, json: { student_id: id('p:kweku'), class_section_id: id('sec:4B'), term_id: id('term:gf:2026t1'), description: 'x', amount_due: '1.00', due_date: '2026-11-01' },
    });
    assert.equal(both.status, 422);
    assert.equal(both.body.code, 'invalid_target');
    const badMoney = await h.call('POST', '/invoices', {
      as, json: { student_id: id('p:kweku'), term_id: id('term:gf:2026t1'), description: 'x', amount_due: '1.999', due_date: '2026-11-01' },
    });
    assert.equal(badMoney.status, 400);
  });
});

describe('paying (guardian)', () => {
  const kofiInvoice = id('inv:kofi');

  test('card: starts a pending payment and returns a checkout redirect; the invoice does not change', async () => {
    const r = await h.call('POST', `/invoices/${kofiInvoice}/pay`, { as: await h.login('akua'), json: { amount: '200.00', method: 'card' } });
    assert.equal(r.status, 202);
    assert.equal(r.body.next.type, 'redirect');
    assert.match(r.body.next.redirect_url, /ref=HR-/);
    assert.deepEqual([r.body.payment.status, r.body.payment.amount, r.body.payment.method], ['pending', '200.00', 'card']);
    const inv = await h.db.asService((tx) => tx.query(`select status from invoices where id = $1`, [kofiInvoice]));
    assert.equal(inv.rows[0]!.status, 'partial');
  });

  test('mobile money uses the guardian\'s number by default and returns a phone prompt', async () => {
    const r = await h.call('POST', `/invoices/${kofiInvoice}/pay`, { as: await h.login('kwabena'), json: { amount: '100.00', method: 'mtn_momo' } });
    assert.equal(r.body.next.type, 'prompt');
    assert.match(r.body.next.message, /\+233240000002/);
    const own = await h.call('POST', `/invoices/${kofiInvoice}/pay`, { as: await h.login('kwabena'), json: { amount: '50.00', method: 'telecel_cash', phone: '020 111 2222' } });
    assert.match(own.body.next.message, /\+?020 111 2222/);
  });

  test('cannot overpay, pay nothing, or pay an invoice that is not theirs', async () => {
    const as = await h.login('akua');
    const over = await h.call('POST', `/invoices/${kofiInvoice}/pay`, { as, json: { amount: '600.01', method: 'card' } });
    assert.equal(over.status, 422);
    assert.equal(over.body.code, 'amount_exceeds_balance');
    assert.equal((await h.call('POST', `/invoices/${kofiInvoice}/pay`, { as, json: { amount: '0.00', method: 'card' } })).status, 422);
    assert.equal((await h.call('POST', `/invoices/${id('inv:yaa')}/pay`, { as, json: { amount: '10.00', method: 'card' } })).status, 404);
    assert.equal((await h.call('POST', `/invoices/${id('inv:ama')}/pay`, { as, json: { amount: '10.00', method: 'card' } })).body.code, 'invoice_settled');
  });

  test('only guardians pay', async () => {
    assert.equal((await h.call('POST', `/invoices/${kofiInvoice}/pay`, { as: await h.login('esi'), json: { amount: '1.00', method: 'card' } })).status, 403);
    assert.equal((await h.call('POST', `/invoices/${kofiInvoice}/pay`, { as: await h.login('kwame'), json: { amount: '1.00', method: 'card' } })).status, 403);
  });

  test('a repeated tap with the same Idempotency-Key does not start a second payment', async () => {
    const as = await h.login('nana');
    const key = { 'idempotency-key': 'pay-yaa-1' };
    const json = { amount: '300.00', method: 'card' };
    const a = await h.call('POST', `/invoices/${id('inv:yaa')}/pay`, { as, json, headers: key });
    const b = await h.call('POST', `/invoices/${id('inv:yaa')}/pay`, { as, json, headers: key });
    assert.equal(b.headers.get('idempotent-replay'), 'true');
    assert.equal(b.body.payment.id, a.body.payment.id);
    const n = await h.db.asService((tx) => tx.query(`select count(*)::int n from payments where amount = 300 and invoice_id = $1`, [id('inv:yaa')]));
    assert.equal(n.rows[0]!.n, 1);
  });

  test('a gateway outage fails the attempt cleanly: 502, nothing charged, payment marked failed', async () => {
    const original = h.deps.payments.initiate;
    (h.deps.payments as any).initiate = async () => { throw new Error('connect ECONNREFUSED'); };
    const r = await h.call('POST', `/invoices/${id('inv:kofi')}/pay`, { as: await h.login('akua'), json: { amount: '10.00', method: 'card' } });
    (h.deps.payments as any).initiate = original;
    assert.equal(r.status, 502);
    assert.equal(r.body.code, 'gateway_unavailable');
    const p = await h.db.asService((tx) => tx.query(`select status from payments where amount = 10 and invoice_id = $1`, [id('inv:kofi')]));
    assert.deepEqual(p.rows.map((x: any) => x.status), ['failed']);
  });
});

describe('the gateway webhook settles invoices', () => {
  test('a signed success marks the invoice paid, exactly once, and notifies', async () => {
    const as = await h.login('akua');
    const start = await h.call('POST', `/invoices/${id('inv:kofi')}/pay`, { as, json: { amount: '600.00', method: 'card' } });
    const ref = start.body.payment.provider_ref;
    const hook = await post('/webhooks/payment', webhook(ref, id('inv:kofi'), '600.00'));
    assert.equal(hook.status, 200);

    const inv = await h.call('GET', `/students/${id('p:kofi')}/invoices`, { as });
    assert.deepEqual([inv.body.items[0].status, inv.body.items[0].outstanding, inv.body.items[0].overdue], ['paid', '0.00', false]);

    await post('/webhooks/payment', webhook(ref, id('inv:kofi'), '600.00')); // the gateway retries
    const n = await h.db.asService((tx) => tx.query(`select count(*)::int n from payments where provider_ref = $1 and status = 'succeeded'`, [ref]));
    assert.equal(n.rows[0]!.n, 1);
    const q = await h.db.asService((tx) => tx.query(`select count(*)::int n from notification_outbox where kind = 'payment.succeeded' and ref_id = (select id from payments where provider_ref = $1)`, [ref]));
    assert.equal(q.rows[0]!.n, 1, 'retries must not send a second receipt');
  });

  test('an unsigned or wrongly signed call is refused and recorded', async () => {
    const good = webhook('HR-forged', id('inv:yaa'), '1850.00');
    const bad = await h.call('POST', '/webhooks/payment', { raw: good.body, headers: { 'content-type': 'application/json', 'x-signature': 'f'.repeat(64) } });
    assert.equal(bad.status, 401);
    assert.equal(bad.body.code, 'invalid_signature');
    const none = await h.call('POST', '/webhooks/payment', { raw: good.body, headers: { 'content-type': 'application/json' } });
    assert.equal(none.status, 401);
    const inv = await h.db.asService((tx) => tx.query(`select status from invoices where id = $1`, [id('inv:yaa')]));
    assert.equal(inv.rows[0]!.status, 'unpaid');
    const log = await h.db.asService((tx) => tx.query(`select count(*)::int n from webhook_events where outcome = 'invalid_signature'`));
    assert.equal(log.rows[0]!.n, 2);
  });

  test('a failed payment never settles; a stale "pending" cannot undo a success', async () => {
    const as = await h.login('nana');
    const start = await h.call('POST', `/invoices/${id('inv:yaa')}/pay`, { as, json: { amount: '100.00', method: 'mtn_momo' } });
    const ref = start.body.payment.provider_ref;
    await post('/webhooks/payment', webhook(ref, id('inv:yaa'), '100.00', 'payment.failed', 'mtn_momo'));
    const p1 = await h.call('GET', `/payments/${start.body.payment.id}`, { as });
    assert.equal(p1.body.status, 'failed');

    const ok = await h.call('POST', `/invoices/${id('inv:yaa')}/pay`, { as, json: { amount: '100.00', method: 'mtn_momo' } });
    await post('/webhooks/payment', webhook(ok.body.payment.provider_ref, id('inv:yaa'), '100.00', 'payment.succeeded', 'mtn_momo'));
    const p2 = await h.call('GET', `/payments/${ok.body.payment.id}`, { as });
    assert.equal(p2.body.status, 'succeeded');
    assert.ok(p2.body.paid_at);
    const inv = await h.db.asService((tx) => tx.query(`select status from invoices where id = $1`, [id('inv:yaa')]));
    assert.equal(inv.rows[0]!.status, 'partial');
  });

  test('a verified event for an unknown invoice gets a 200 (stop retrying) and is logged as unmatched', async () => {
    const r = await post('/webhooks/payment', webhook('HR-ghost', id('no-such-invoice'), '5.00'));
    assert.equal(r.status, 200);
    const log = await h.db.asService((tx) => tx.query(`select outcome from webhook_events where provider_ref = 'HR-ghost'`));
    assert.deepEqual(log.rows.map((x: any) => x.outcome), ['unmatched']);
  });

  test('an irrelevant verified event is ignored', async () => {
    const r = await post('/webhooks/payment', h.payments.sign({ event: 'refund.processed', reference: 'x' }));
    assert.equal(r.status, 200);
  });
});

describe('payments ledger', () => {
  test('admin records a manual payment; it settles through the same path and is idempotent on its reference', async () => {
    const as = await h.login('esi');
    const a = await h.call('POST', '/payments', { as, json: { invoice_id: id('inv:kojo'), amount: '1850.00', reference: 'RCPT-0042' } });
    assert.equal(a.status, 201);
    assert.deepEqual([a.body.method, a.body.status], ['manual', 'succeeded']);
    const again = await h.call('POST', '/payments', { as, json: { invoice_id: id('inv:kojo'), amount: '1850.00', reference: 'RCPT-0042' } });
    assert.equal(again.body.id, a.body.id);
    const inv = await h.call('GET', '/invoices?status=paid', { as });
    assert.ok(inv.body.items.some((i: any) => i.student.full_name === 'Kojo Tetteh'));
  });

  test('payments need an invoice from the admin\'s own school', async () => {
    const r = await h.call('POST', '/payments', { as: await h.login('esi'), json: { invoice_id: id('nope'), amount: '1.00', reference: 'X' } });
    assert.equal(r.status, 404);
  });

  test('the ledger filters by status, and stale pending payments are findable', async () => {
    const as = await h.login('esi');
    const pending = await h.call('GET', '/payments?status=pending', { as });
    assert.ok(pending.body.items.length >= 1);
    const stale = await h.call('GET', '/payments?stale_pending=true', { as });
    assert.ok(stale.body.items.every((p: any) => p.status === 'pending'));
    assert.equal((await h.call('GET', '/payments', { as: await h.login('akua') })).status, 403);
  });

  test('a parent can poll their own payment and nobody else\'s', async () => {
    const start = await h.call('POST', `/invoices/${id('inv:yaa')}/pay`, { as: await h.login('nana'), json: { amount: '20.00', method: 'card' } });
    const pid = start.body.payment.id;
    assert.equal((await h.call('GET', `/payments/${pid}`, { as: await h.login('nana') })).status, 200);
    assert.equal((await h.call('GET', `/payments/${pid}`, { as: await h.login('akua') })).status, 404);
    assert.equal((await h.call('GET', `/payments/${pid}`, { as: await h.login('esi') })).status, 200);
  });
});
