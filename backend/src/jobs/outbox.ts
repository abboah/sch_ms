import type { Deps, Tx } from '../context.ts';
import { SMS_KINDS, expand, type Draft, type OutboxEvent } from './notifications.ts';

const MAX_ATTEMPTS = 5;

export interface OutboxResult {
  processed: number;
  failed: number;
}

/**
 * Drain the notification outbox. Each event is handled in its own transaction: claim it
 * (`for update skip locked`, so several workers can run at once), expand it into inbox rows,
 * deliver, mark it done. A failure rolls back that event only and schedules a retry with
 * exponential backoff; after MAX_ATTEMPTS it is parked as `failed` with the error for a human.
 * Delivery is at-least-once: a crash between sending and committing can repeat a push, never lose one.
 */
export async function processOutbox(deps: Deps, opts: { limit?: number } = {}): Promise<OutboxResult> {
  const result: OutboxResult = { processed: 0, failed: 0 };
  const limit = opts.limit ?? 100;

  for (let i = 0; i < limit; i++) {
    const now = deps.clock.now();
    let eventId: number | null = null;
    try {
      const handled = await deps.db.asService(async (tx) => {
        const r = await tx.query<OutboxEvent>(
          `select id, school_id, kind, ref_id, student_id, payload from notification_outbox
            where status = 'pending' and run_after <= $1 order by id limit 1 for update skip locked`,
          [now],
        );
        const event = r.rows[0];
        if (!event) return false;
        eventId = event.id;
        const drafts = await expand(tx, event);
        for (const d of drafts) await deliver(deps, tx, event, d, now);
        await tx.query(`update notification_outbox set status = 'done', processed_at = $2, last_error = null where id = $1`, [event.id, now]);
        return true;
      });
      if (!handled) break;
      result.processed++;
    } catch (err) {
      result.failed++;
      deps.log.error('outbox event failed', { eventId, err });
      if (eventId !== null) {
        const id = eventId;
        await deps.db.asService((tx) =>
          tx.query(
            `update notification_outbox
                set attempts = attempts + 1, last_error = $2,
                    status = case when attempts + 1 >= $3 then 'failed' else 'pending' end,
                    run_after = $4::timestamptz + least(3600, 30 * power(2, attempts)) * interval '1 second'
              where id = $1`,
            [id, String((err as Error).message).slice(0, 500), MAX_ATTEMPTS, now],
          ),
        );
      }
      // Keep draining: one poison event must not block the rest.
    }
  }
  return result;
}

async function deliver(deps: Deps, tx: Tx, event: OutboxEvent, d: Draft, now: Date): Promise<void> {
  const n = await tx.query<{ id: string }>(
    `insert into notifications (school_id, person_id, kind, title, body, data, created_at)
     values ($1, $2, $3, $4, $5, $6, $7) returning id`,
    [event.school_id, d.personId, event.kind, d.title, d.body, JSON.stringify(d.data), now],
  );
  const notificationId = n.rows[0]!.id;
  const record = (channel: 'push' | 'sms' | 'email', status: 'sent' | 'failed' | 'skipped', detail?: string) =>
    tx.query('insert into notification_deliveries (notification_id, channel, status, detail, at) values ($1, $2, $3, $4, $5)', [
      notificationId, channel, status, detail ?? null, now,
    ]);

  const prefs = (await tx.query<{ push: boolean; email: boolean; sms: boolean }>(
    'select push, email, sms from notification_prefs where person_id = $1', [d.personId],
  )).rows[0] ?? { push: true, email: true, sms: true };
  const contact = (await tx.query<{ phone: string | null; email: string | null }>(
    'select phone, email from person_contacts where person_id = $1', [d.personId],
  )).rows[0];
  const tokens = prefs.push
    ? (await tx.query<{ token: string; platform: 'ios' | 'android' | 'web' }>('select token, platform from push_tokens where person_id = $1', [d.personId])).rows
    : [];

  // Push first. A send failure is recorded and falls through to SMS, it does not fail the event.
  let pushed = false;
  if (!prefs.push) await record('push', 'skipped', 'turned off by the user');
  else if (tokens.length === 0) await record('push', 'skipped', 'no registered device');
  else {
    try {
      const res = await deps.push.send(tokens, { title: d.title, body: d.body, data: d.data });
      pushed = true;
      await record('push', 'sent', `${tokens.length} device(s)`);
      if (res.invalidTokens.length) {
        await tx.query('delete from push_tokens where token = any($1::text[])', [res.invalidTokens]);
      }
    } catch (err) {
      await record('push', 'failed', (err as Error).message.slice(0, 200));
    }
  }

  // SMS covers people without the app (or whose push failed) for time-sensitive kinds only.
  if (!pushed && SMS_KINDS.has(event.kind)) {
    if (!prefs.sms) await record('sms', 'skipped', 'turned off by the user');
    else if (!contact?.phone) await record('sms', 'skipped', 'no phone number');
    else {
      try {
        await deps.sms.send(contact.phone, `${d.title}: ${d.body}`.slice(0, 300));
        await record('sms', 'sent');
      } catch (err) {
        await record('sms', 'failed', (err as Error).message.slice(0, 200));
      }
    }
  }

  if (d.email && prefs.email && contact?.email) {
    try {
      await deps.email.send(contact.email, d.email.subject, d.email.text);
      await record('email', 'sent');
    } catch (err) {
      await record('email', 'failed', (err as Error).message.slice(0, 200));
    }
  }
}

/**
 * Enqueue a reminder for every invoice that falls due within `days` and still owes money,
 * once per invoice per due date. Safe to run as often as you like.
 */
export async function enqueueFeesDueSoon(deps: Deps, days = 3): Promise<number> {
  const r = await deps.db.asService((tx) =>
    tx.query(
      `insert into notification_outbox (school_id, kind, ref_id, student_id, payload)
       select i.school_id, 'fees.due_soon', i.id, i.student_id, jsonb_build_object('due_date', i.due_date)
         from invoices i
        where i.status in ('unpaid', 'partial')
          and i.due_date between $1::date and ($1::date + $2::int)
          and not exists (select 1 from notification_outbox o
                           where o.kind = 'fees.due_soon' and o.ref_id = i.id and o.payload->>'due_date' = i.due_date::text)
        returning id`,
      [deps.clock.now().toISOString().slice(0, 10), days],
    ),
  );
  return r.rowCount;
}
