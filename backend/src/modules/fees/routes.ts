import { createHash, randomUUID } from 'node:crypto';
import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps, Tx } from '../../context.ts';
import { AppError, conflict, notFound, unauthorized, unprocessable } from '../../http/errors.ts';
import { asCaller, body, decodeCursor, idParam, iso, money, pageQuery, paginate, query, uuid, type Schemas } from '../../http/helpers.ts';
import { requireRole } from '../../http/middleware.ts';
import { schoolTimezone, studentRef, todayIn, visibleStudent } from '../shared.ts';

const moneyString = z.string().regex(/^\d{1,9}(\.\d{1,2})?$/, 'expected an amount like 600.00');
const cents = (s: string | number): number => Math.round(Number(s) * 100);

interface InvoiceRow {
  id: string; student_id: string; full_name: string; term_id: string; description: string;
  amount_due: string; status: Schemas['Invoice']['status']; due_date: string; paid: string; fee_item_id: string | null;
}
interface FeeItemRow { id: string; name: string; default_amount: string; active: boolean }
const toFeeItem = (f: FeeItemRow): Schemas['FeeItem'] => ({ id: f.id, name: f.name, default_amount: money(f.default_amount), active: f.active });
interface PaymentRow {
  id: string; invoice_id: string; amount: string; method: Schemas['Payment']['method'];
  status: Schemas['PaymentStatus']; provider_ref: string; paid_at: Date | null; created_at: Date;
  student_id?: string; student_name?: string; description?: string;
}

export const toPayment = (p: PaymentRow): Schemas['Payment'] => ({
  id: p.id,
  invoice_id: p.invoice_id,
  amount: money(p.amount),
  method: p.method,
  status: p.status,
  provider_ref: p.provider_ref,
  paid_at: iso(p.paid_at),
  created_at: p.created_at.toISOString(),
  receipt_url: null,
  ...(p.student_id && p.student_name ? { student: studentRef({ id: p.student_id, full_name: p.student_name }) } : {}),
  ...(p.description ? { description: p.description } : {}),
});

const INVOICE_SELECT = `
  select i.id, i.student_id, st.full_name, i.term_id, i.description, i.amount_due, i.status, i.due_date, i.fee_item_id,
         coalesce((select sum(p.amount) from payments p where p.invoice_id = i.id and p.status = 'succeeded'), 0) as paid
    from invoices i join people st on st.id = i.student_id`;

function toInvoice(i: InvoiceRow, today: string, payments: Schemas['Payment'][]): Schemas['Invoice'] {
  const outstanding = Math.max(0, cents(i.amount_due) - cents(i.paid));
  return {
    id: i.id,
    student: studentRef({ id: i.student_id, full_name: i.full_name }),
    term_id: i.term_id,
    description: i.description,
    amount_due: money(i.amount_due),
    amount_paid: money(i.paid),
    outstanding: (outstanding / 100).toFixed(2),
    status: i.status,
    due_date: i.due_date,
    overdue: i.status !== 'void' && outstanding > 0 && i.due_date < today,
    fee_item_id: i.fee_item_id,
    payments,
  };
}

async function withPayments(tx: Tx, rows: InvoiceRow[], today: string): Promise<Schemas['Invoice'][]> {
  if (rows.length === 0) return [];
  const pays = await tx.query<PaymentRow>(
    `select id, invoice_id, amount, method, status, provider_ref, paid_at, created_at from payments
      where invoice_id = any($1::uuid[]) order by created_at, id`,
    [rows.map((r) => r.id)],
  );
  const by = new Map<string, Schemas['Payment'][]>();
  for (const p of pays.rows) by.set(p.invoice_id, [...(by.get(p.invoice_id) ?? []), toPayment(p)]);
  return rows.map((r) => toInvoice(r, today, by.get(r.id) ?? []));
}

const feeItemInput = z.object({
  name: z.string().min(1).max(120),
  default_amount: moneyString,
  active: z.boolean().default(true),
});

export function feesRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();
  const admin = requireRole('admin');
  const money_ = requireRole('admin', 'guardian');

  /** Reusable named charges (e.g. "Term 1 Tuition"). A convenience + reporting tag for invoices,
   *  not a source of truth: an invoice keeps its own description and amount either way. */
  r.get('/fee_items', admin, async (c) =>
    c.json({
      items: await asCaller(deps, c, async (tx) => {
        const rows = await tx.query<FeeItemRow>('select id, name, default_amount, active from fee_items order by name');
        return rows.rows.map(toFeeItem);
      }),
    }),
  );

  r.post('/fee_items', admin, async (c) => {
    const b = await body(c, feeItemInput);
    const out = await asCaller(deps, c, async (tx, me) => {
      const row = await tx.query<FeeItemRow>(
        `insert into fee_items (school_id, name, default_amount, active) values ($1, $2, $3, $4)
         returning id, name, default_amount, active`,
        [me.schoolId, b.name, b.default_amount, b.active],
      );
      return toFeeItem(row.rows[0]!);
    });
    return c.json(out, 201);
  });

  r.patch('/fee_items/:id', admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, feeItemInput.partial());
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const row = await tx.query<FeeItemRow>(
          `update fee_items set name = coalesce($2, name), default_amount = coalesce($3, default_amount), active = coalesce($4, active)
            where id = $1 returning id, name, default_amount, active`,
          [id, b.name ?? null, b.default_amount ?? null, b.active ?? null],
        );
        if (!row.rows[0]) throw notFound('Fee item');
        return toFeeItem(row.rows[0]);
      }),
    );
  });

  r.get('/students/:id/invoices', money_, async (c) => {
    const id = idParam(c);
    return c.json({
      items: await asCaller(deps, c, async (tx) => {
        await visibleStudent(tx, id, 'student_invoices');
        const today = todayIn(await schoolTimezone(tx), deps.clock.now());
        const rows = await tx.query<InvoiceRow>(`${INVOICE_SELECT} where i.student_id = $1 order by i.due_date desc, i.id`, [id]);
        return withPayments(tx, rows.rows, today);
      }),
    });
  });

  r.get('/invoices', admin, async (c) => {
    const q = query(
      c,
      pageQuery.extend({ status: z.enum(['unpaid', 'partial', 'paid', 'void', 'overdue']).optional(), term_id: uuid.optional() }),
    );
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps, c, async (tx): Promise<Schemas['InvoicePage']> => {
        const today = todayIn(await schoolTimezone(tx), deps.clock.now());
        const params: unknown[] = [q.limit + 1];
        const where: string[] = [];
        if (q.term_id) { params.push(q.term_id); where.push(`x.term_id = $${params.length}`); }
        if (q.status === 'overdue') {
          params.push(today);
          where.push(`x.status <> 'void' and x.amount_due - x.paid > 0 and x.due_date < $${params.length}::date`);
        }
        else if (q.status) { params.push(q.status); where.push(`x.status = $${params.length}::invoice_status`); }
        if (cur) { params.push(cur.t, cur.id); where.push(`(x.due_date, x.id) < ($${params.length - 1}::date, $${params.length}::uuid)`); }
        const rows = await tx.query<InvoiceRow>(
          `select * from (${INVOICE_SELECT}) x ${where.length ? 'where ' + where.join(' and ') : ''}
            order by x.due_date desc, x.id desc limit $1`,
          params,
        );
        const page = paginate(rows.rows, q.limit, (i) => i.due_date);
        return { items: await withPayments(tx, page.items, today), next_cursor: page.next_cursor };
      }),
    );
  });

  r.post('/invoices', admin, async (c) => {
    const b = await body(
      c,
      z.object({
        student_id: uuid.optional(),
        class_section_id: uuid.optional(),
        term_id: uuid,
        description: z.string().min(1).max(200),
        amount_due: moneyString,
        due_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
        fee_item_id: uuid.optional(),
      }),
    );
    if (!!b.student_id === !!b.class_section_id) {
      throw unprocessable('Give exactly one of student_id or class_section_id', 'invalid_target');
    }
    const items = await asCaller(deps, c, async (tx) => {
      const ids = b.student_id
        ? await tx.query<{ id: string }>(
            `insert into invoices (school_id, student_id, term_id, description, amount_due, due_date, fee_item_id)
             values (app.school_id(), $1, $2, $3, $4, $5, $6) returning id`,
            [b.student_id, b.term_id, b.description, b.amount_due, b.due_date, b.fee_item_id ?? null],
          )
        : await tx.query<{ id: string }>(
            `insert into invoices (school_id, student_id, term_id, description, amount_due, due_date, fee_item_id)
             select app.school_id(), e.student_id, $2, $3, $4, $5, $6 from enrollments e
              where e.class_section_id = $1 and e.status = 'active' returning id`,
            [b.class_section_id, b.term_id, b.description, b.amount_due, b.due_date, b.fee_item_id ?? null],
          );
      const today = todayIn(await schoolTimezone(tx), deps.clock.now());
      const rows = await tx.query<InvoiceRow>(`${INVOICE_SELECT} where i.id = any($1::uuid[]) order by st.full_name`, [ids.rows.map((x) => x.id)]);
      return withPayments(tx, rows.rows, today);
    });
    return c.json({ items }, 201);
  });

  /**
   * Starts a payment; it never settles one. The pending row is written with the service-role
   * settlement function (guardians have no write access to payments by design), then the gateway
   * is asked to collect. Only the signed webhook moves the invoice to paid.
   */
  r.post('/invoices/:id/pay', requireRole('guardian'), async (c) => {
    const invoiceId = idParam(c);
    const b = await body(c, z.object({ amount: moneyString, method: z.enum(['card', 'mtn_momo', 'telecel_cash']), phone: z.string().min(6).max(25).optional() }));

    const prep = await asCaller(deps, c, async (tx, me) => {
      const inv = await tx.query<InvoiceRow>(`${INVOICE_SELECT} where i.id = $1`, [invoiceId]);
      const row = inv.rows[0];
      if (!row) throw notFound('Invoice');
      if (row.status === 'void' || row.status === 'paid') throw conflict('This invoice needs no further payment', 'invoice_settled');
      const outstanding = cents(row.amount_due) - cents(row.paid);
      const amount = cents(b.amount);
      if (amount <= 0 || amount > outstanding) {
        throw unprocessable(`Enter an amount between 0.01 and ${(outstanding / 100).toFixed(2)}`, 'amount_exceeds_balance');
      }
      const contact = await tx.query<{ phone: string | null; email: string | null }>(
        'select phone, email from person_contacts where person_id = $1',
        [me.personId],
      );
      const phone = b.phone ?? contact.rows[0]?.phone ?? undefined;
      if (b.method !== 'card' && !phone) throw unprocessable('A mobile number is needed for mobile money', 'phone_required');
      return { phone, email: contact.rows[0]?.email ?? undefined, amount: (amount / 100).toFixed(2) };
    });

    const reference = `HR-${randomUUID()}`;
    await deps.db.asService((tx) =>
      tx.query(`select apply_payment_webhook($1, $2, $3, $4::payment_method, 'pending')`, [reference, invoiceId, prep.amount, b.method]),
    );

    let next: Schemas['PaymentStart']['next'];
    try {
      const res = await deps.payments.initiate({
        reference, amount: prep.amount, currency: 'GHS', method: b.method, phone: prep.phone, email: prep.email,
        callbackUrl: `${deps.config.PUBLIC_WEB_URL}/#/parent/fees`,
        metadata: { invoice_id: invoiceId },
      });
      next = res.type === 'redirect' ? { type: 'redirect', redirect_url: res.redirectUrl } : { type: 'prompt', message: res.message };
    } catch (err) {
      c.var.log.error('payment gateway initiate failed', { err, reference });
      await deps.db.asService((tx) =>
        tx.query(`select apply_payment_webhook($1, $2, $3, $4::payment_method, 'failed')`, [reference, invoiceId, prep.amount, b.method]),
      );
      throw new AppError(502, 'gateway_unavailable', 'The payment provider could not be reached. Nothing was charged.');
    }

    const pay = await deps.db.asService((tx) =>
      tx.query<PaymentRow>('select id, invoice_id, amount, method, status, provider_ref, paid_at, created_at from payments where provider_ref = $1', [reference]),
    );
    return c.json({ payment: toPayment(pay.rows[0]!), next }, 202);
  });

  r.get('/payments', admin, async (c) => {
    const q = query(c, pageQuery.extend({ status: z.enum(['pending', 'succeeded', 'failed']).optional(), stale_pending: z.enum(['true', 'false']).optional() }));
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const params: unknown[] = [q.limit + 1];
        const where: string[] = [];
        if (q.status) { params.push(q.status); where.push(`status = $${params.length}::payment_status`); }
        if (q.stale_pending === 'true') {
          params.push(new Date(deps.clock.now().getTime() - 30 * 60 * 1000));
          where.push(`status = 'pending' and created_at < $${params.length}`);
        }
        if (cur) { params.push(cur.t, cur.id); where.push(`(created_at, id) < ($${params.length - 1}::timestamptz, $${params.length}::uuid)`); }
        const rows = await tx.query<PaymentRow>(
          `select * from (
             select p.id, p.invoice_id, p.amount, p.method, p.status, p.provider_ref, p.paid_at, p.created_at,
                    i.student_id, st.full_name as student_name, i.description
               from payments p join invoices i on i.id = p.invoice_id join people st on st.id = i.student_id) p
            ${where.length ? 'where ' + where.join(' and ') : ''} order by created_at desc, id desc limit $1`,
          params,
        );
        const page = paginate(rows.rows, q.limit, (p) => p.created_at.toISOString());
        return { items: page.items.map(toPayment), next_cursor: page.next_cursor };
      }),
    );
  });

  r.post('/payments', admin, async (c) => {
    const b = await body(c, z.object({ invoice_id: uuid, amount: moneyString, reference: z.string().min(1).max(80) }));
    const out = await asCaller(deps, c, async (tx) => {
      const inv = await tx.query('select 1 from invoices where id = $1', [b.invoice_id]);
      if (inv.rowCount === 0) throw notFound('Invoice'); // also guards against another school's invoice id
      return true;
    }).then(async () => {
      const ref = `manual:${b.reference}`;
      await deps.db.asService((tx) =>
        tx.query(`select apply_payment_webhook($1, $2, $3, 'manual', 'succeeded')`, [ref, b.invoice_id, b.amount]),
      );
      const p = await deps.db.asService((tx) =>
        tx.query<PaymentRow>('select id, invoice_id, amount, method, status, provider_ref, paid_at, created_at from payments where provider_ref = $1', [ref]),
      );
      return toPayment(p.rows[0]!);
    });
    return c.json(out, 201);
  });

  r.get('/payments/:id', money_, async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const p = await tx.query<PaymentRow>('select id, invoice_id, amount, method, status, provider_ref, paid_at, created_at from payments where id = $1', [id]);
        if (!p.rows[0]) throw notFound('Payment');
        return toPayment(p.rows[0]);
      }),
    );
  });

  return r;
}

/**
 * The gateway's callback. Not user-authenticated: trust comes from the signature. Every call is
 * recorded in webhook_events, valid or not, so a missing payment can always be traced.
 * A verified event always gets a 200, even if we could not match it, so the gateway stops retrying;
 * unmatched ones are logged for a human.
 */
export function webhookRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();

  r.post('/payment', async (c) => {
    const raw = await c.req.text();
    const sha = createHash('sha256').update(raw).digest('hex');
    const record = (outcome: string, extra: { ref?: string; invoice?: string; detail?: string } = {}) =>
      deps.db.asService((tx) =>
        tx.query(
          `insert into webhook_events (provider, outcome, provider_ref, invoice_id, body_sha256, detail) values ($1, $2, $3, $4, $5, $6)`,
          [deps.payments.name, outcome, extra.ref ?? null, extra.invoice ?? null, sha, extra.detail ?? null],
        ),
      );

    if (!deps.payments.verifyWebhook(raw, c.req.raw.headers)) {
      await record('invalid_signature');
      c.var.log.warn('payment webhook rejected: bad signature', { sha });
      throw unauthorized('Invalid signature', 'invalid_signature');
    }

    let event;
    try {
      event = deps.payments.parseWebhook(raw);
    } catch (err) {
      await record('error', { detail: 'unparseable body' });
      throw new AppError(400, 'invalid_webhook', `Could not parse webhook: ${(err as Error).message}`);
    }
    if (!event) {
      await record('ignored');
      return c.body(null, 200);
    }

    try {
      await deps.db.asService((tx) =>
        tx.query(`select apply_payment_webhook($1, $2, $3, $4::payment_method, $5::payment_status)`, [
          event.providerRef, event.invoiceId, event.amount, event.method, event.status,
        ]),
      );
      await record('processed', { ref: event.providerRef, invoice: event.invoiceId });
    } catch (err) {
      const code = (err as { code?: string }).code;
      if (code === 'P0002' || code === '22P02') {
        await record('unmatched', { ref: event.providerRef, detail: (err as Error).message });
        c.var.log.warn('payment webhook for unknown invoice', { ref: event.providerRef, invoice: event.invoiceId });
        return c.body(null, 200);
      }
      await record('error', { ref: event.providerRef, invoice: event.invoiceId, detail: (err as Error).message });
      throw err; // let the gateway retry
    }
    return c.body(null, 200);
  });

  return r;
}
