import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps } from '../../context.ts';
import {
  asCaller, body, decodeCursor, iso, pageQuery, paginate, query, uuid, type Schemas,
} from '../../http/helpers.ts';
import { loadMe } from './service.ts';
import { normalizePhone } from '../../auth/phone.ts';

const prefsSchema = z.object({ push: z.boolean(), email: z.boolean(), sms: z.boolean() });

export function meRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();

  r.get('/me', async (c) => c.json(await asCaller(deps, c, (tx, me) => loadMe(tx, me.personId, deps.clock.now()))));

  r.get('/me/notification_prefs', async (c) =>
    c.json(
      await asCaller(deps, c, async (tx, me): Promise<Schemas['NotificationPrefs']> => {
        const p = await tx.query<Schemas['NotificationPrefs']>(
          'select push, email, sms from notification_prefs where person_id = $1',
          [me.personId],
        );
        return p.rows[0] ?? { push: true, email: true, sms: true };
      }),
    ),
  );

  r.put('/me/notification_prefs', async (c) => {
    const prefs = await body(c, prefsSchema);
    return c.json(
      await asCaller(deps, c, async (tx, me): Promise<Schemas['NotificationPrefs']> => {
        await tx.query(
          `insert into notification_prefs (person_id, push, email, sms) values ($1, $2, $3, $4)
           on conflict (person_id) do update set push = excluded.push, email = excluded.email, sms = excluded.sms`,
          [me.personId, prefs.push, prefs.email, prefs.sms],
        );
        return prefs;
      }),
    );
  });

  r.put('/me/contact', async (c) => {
    // Omitted field = keep, null = clear.
    const b = await body(c, z.object({ phone: z.string().nullable().optional(), email: z.email().nullable().optional() }));
    return c.json(
      await asCaller(deps, c, async (tx, me): Promise<Schemas['Contact']> => {
        const cur = await tx.query<{ phone: string | null; email: string | null }>(
          'select phone, email from person_contacts where person_id = $1',
          [me.personId],
        );
        const prev = cur.rows[0] ?? { phone: null, email: null };
        const phone = b.phone === undefined ? prev.phone : b.phone === null ? null : normalizePhone(b.phone, deps.config.DEFAULT_COUNTRY_CODE);
        const email = b.email === undefined ? prev.email : b.email === null ? null : b.email.toLowerCase();
        await tx.query(
          `insert into person_contacts (person_id, school_id, phone, email) values ($1, $2, $3, $4)
           on conflict (person_id) do update set phone = excluded.phone, email = excluded.email`,
          [me.personId, me.schoolId, phone, email],
        );
        return { phone, email };
      }),
    );
  });

  r.post('/me/push_tokens', async (c) => {
    const b = await body(c, z.object({ token: z.string().min(10).max(4096), platform: z.enum(['ios', 'android', 'web']) }));
    await asCaller(deps, c, (tx, me) =>
      tx.query(
        `insert into push_tokens (person_id, token, platform) values ($1, $2, $3)
         on conflict (token) do update set person_id = excluded.person_id, platform = excluded.platform`,
        [me.personId, b.token, b.platform],
      ),
    );
    return c.body(null, 204);
  });

  r.delete('/me/push_tokens/:token', async (c) => {
    await asCaller(deps, c, (tx, me) =>
      tx.query('delete from push_tokens where token = $1 and person_id = $2', [c.req.param('token'), me.personId]),
    );
    return c.body(null, 204);
  });

  r.get('/notifications', async (c) => {
    const q = query(c, pageQuery.extend({ unread: z.enum(['true', 'false']).optional() }));
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps, c, async (tx, me): Promise<Schemas['NotificationPage']> => {
        const params: unknown[] = [me.personId, q.limit + 1];
        let where = 'person_id = $1';
        if (q.unread === 'true') where += ' and read_at is null';
        if (cur) {
          params.push(cur.t, cur.id);
          where += ` and (created_at, id) < ($3::timestamptz, $4::uuid)`;
        }
        const rows = await tx.query<{
          id: string; kind: string; title: string; body: string; data: Record<string, unknown>; read_at: Date | null; created_at: Date;
        }>(
          `select id, kind, title, body, data, read_at, created_at from notifications
            where ${where} order by created_at desc, id desc limit $2`,
          params,
        );
        const unread = await tx.query<{ n: number }>(
          'select count(*)::int as n from notifications where person_id = $1 and read_at is null',
          [me.personId],
        );
        const page = paginate(rows.rows, q.limit, (n) => n.created_at.toISOString());
        return {
          items: page.items.map((n) => ({
            id: n.id, kind: n.kind, title: n.title, body: n.body, data: n.data,
            read_at: iso(n.read_at), created_at: n.created_at.toISOString(),
          })),
          next_cursor: page.next_cursor,
          unread_count: unread.rows[0]?.n ?? 0,
        };
      }),
    );
  });

  r.post('/notifications/read', async (c) => {
    const b = await body(c, z.object({ ids: z.array(uuid).max(500).optional() }));
    await asCaller(deps, c, (tx, me) =>
      b.ids
        ? tx.query('update notifications set read_at = $3 where person_id = $1 and id = any($2::uuid[]) and read_at is null', [me.personId, b.ids, deps.clock.now()])
        : tx.query('update notifications set read_at = $2 where person_id = $1 and read_at is null', [me.personId, deps.clock.now()]),
    );
    return c.body(null, 204);
  });

  return r;
}
