import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps, Tx } from '../../context.ts';
import { forbidden, notFound } from '../../http/errors.ts';
import { asCaller, body, decodeCursor, idParam, iso, pageQuery, paginate, query, uuid, type Schemas } from '../../http/helpers.ts';
import { requireRole } from '../../http/middleware.ts';
import { personRef } from '../shared.ts';

interface AnnRow {
  id: string; class_section_id: string | null; title: string; body: string; requires_response: boolean;
  published_at: Date | null; created_at: Date; author_id: string | null; author_name: string | null; author_role: Schemas['Role'] | null;
}
interface RespRow { announcement_id: string; student_id: string; guardian_id: string; response: 'yes' | 'no'; responded_at: Date }

const toResponse = (x: RespRow): Schemas['AnnouncementResponse'] => ({
  announcement_id: x.announcement_id, student_id: x.student_id, guardian_id: x.guardian_id,
  response: x.response, responded_at: x.responded_at.toISOString(),
});

const ANN_SELECT = `
  select a.id, a.class_section_id, a.title, a.body, a.requires_response, a.published_at, a.created_at,
         au.id as author_id, au.full_name as author_name, au.role as author_role
    from announcements a left join people au on au.id = a.author_id`;

async function mapAnnouncements(tx: Tx, rows: AnnRow[], withMine: boolean): Promise<Schemas['Announcement'][]> {
  const mine = new Map<string, Schemas['AnnouncementResponse'][]>();
  if (withMine && rows.length) {
    const rs = await tx.query<RespRow>(
      'select announcement_id, student_id, guardian_id, response, responded_at from announcement_responses where announcement_id = any($1::uuid[])',
      [rows.map((r) => r.id)],
    );
    for (const x of rs.rows) mine.set(x.announcement_id, [...(mine.get(x.announcement_id) ?? []), toResponse(x)]);
  }
  return rows.map((a) => ({
    id: a.id,
    // Authors the caller cannot see (an administrator, to a parent) are simply omitted.
    ...(a.author_id && a.author_name && a.author_role ? { author: personRef({ id: a.author_id, full_name: a.author_name, role: a.author_role }) } : {}),
    class_section_id: a.class_section_id,
    title: a.title,
    body: a.body,
    requires_response: a.requires_response,
    published_at: iso(a.published_at),
    ...(withMine && a.requires_response ? { my_responses: mine.get(a.id) ?? [] } : {}),
  }));
}

export function announcementRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();

  r.get('/announcements', async (c) => {
    const q = query(c, pageQuery);
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps, c, async (tx, me): Promise<Schemas['AnnouncementPage']> => {
        const params: unknown[] = [q.limit + 1];
        let cursorSql = '';
        if (cur) {
          params.push(cur.t, cur.id);
          cursorSql = `where (coalesce(a.published_at, a.created_at), a.id) < ($2::timestamptz, $3::uuid)`;
        }
        const rows = await tx.query<AnnRow>(
          `${ANN_SELECT} ${cursorSql} order by coalesce(a.published_at, a.created_at) desc, a.id desc limit $1`,
          params,
        );
        const page = paginate(rows.rows, q.limit, (a) => (a.published_at ?? a.created_at).toISOString());
        return { items: await mapAnnouncements(tx, page.items, me.role === 'guardian'), next_cursor: page.next_cursor };
      }),
    );
  });

  r.post('/announcements', requireRole('admin', 'teacher'), async (c) => {
    const b = await body(
      c,
      z.object({
        title: z.string().trim().min(1).max(200),
        body: z.string().trim().min(1).max(10_000),
        class_section_id: uuid.nullable().optional(),
        requires_response: z.boolean().default(false),
        published: z.boolean().default(false),
      }),
    );
    const out = await asCaller(deps, c, async (tx, me) => {
      const now = deps.clock.now();
      try {
        const ins = await tx.attempt(() =>
          tx.query<{ id: string }>(
            `insert into announcements (school_id, author_id, class_section_id, title, body, requires_response, published_at, created_at)
             values (app.school_id(), $1, $2, $3, $4, $5, $6, $7) returning id`,
            [me.personId, b.class_section_id ?? null, b.title, b.body, b.requires_response, b.published ? now : null, now],
          ),
        );
        const rows = await tx.query<AnnRow>(`${ANN_SELECT} where a.id = $1`, [ins.rows[0]!.id]);
        return (await mapAnnouncements(tx, rows.rows, false))[0]!;
      } catch (err) {
        if ((err as { code?: string }).code === '42501')
          throw forbidden(me.role === 'teacher' ? 'Teachers can only post to a class they teach' : 'You cannot post this announcement', 'cannot_post_here');
        throw err;
      }
    });
    return c.json(out, 201);
  });

  r.post('/announcements/:id/publish', requireRole('admin', 'teacher'), async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const cur = await tx.query<{ published_at: Date | null }>('select published_at from announcements where id = $1', [id]);
        if (!cur.rows[0]) throw notFound('Announcement');
        if (!cur.rows[0].published_at) {
          const u = await tx.query('update announcements set published_at = $2 where id = $1', [id, deps.clock.now()]);
          if (u.rowCount === 0) throw forbidden('Only the author or an administrator can publish this', 'not_author');
        }
        const rows = await tx.query<AnnRow>(`${ANN_SELECT} where a.id = $1`, [id]);
        return (await mapAnnouncements(tx, rows.rows, false))[0]!;
      }),
    );
  });

  r.get('/announcements/:id/responses', requireRole('admin'), async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const a = await tx.query<{ class_section_id: string | null; requires_response: boolean }>(
          'select class_section_id, requires_response from announcements where id = $1',
          [id],
        );
        if (!a.rows[0]) throw notFound('Announcement');
        const rs = await tx.query<RespRow>(
          'select announcement_id, student_id, guardian_id, response, responded_at from announcement_responses where announcement_id = $1 order by responded_at',
          [id],
        );
        // Everyone the notice was addressed to: the class, or every enrolled child in the school.
        const audience = await tx.query<{ n: number }>(
          `select count(distinct e.student_id)::int as n from enrollments e
             join class_sections cs on cs.id = e.class_section_id join terms t on t.id = cs.term_id and not t.closed
            where e.status = 'active' and ($1::uuid is null or e.class_section_id = $1)`,
          [a.rows[0].class_section_id],
        );
        const yes = rs.rows.filter((x) => x.response === 'yes').length;
        const no = rs.rows.length - yes;
        return { yes, no, awaiting: Math.max(0, (audience.rows[0]?.n ?? 0) - rs.rows.length), items: rs.rows.map(toResponse) };
      }),
    );
  });

  r.put('/announcements/:id/responses', requireRole('guardian'), async (c) => {
    const id = idParam(c);
    const b = await body(c, z.object({ student_id: uuid, response: z.enum(['yes', 'no']) }));
    return c.json(
      await asCaller(deps, c, async (tx, me): Promise<Schemas['AnnouncementResponse']> => {
        const a = await tx.query<{ requires_response: boolean }>('select requires_response from announcements where id = $1', [id]);
        if (!a.rows[0]) throw notFound('Announcement');
        if (!a.rows[0].requires_response) throw forbidden('This announcement does not ask for a reply', 'no_response_expected');
        try {
          const u = await tx.attempt(() =>
            tx.query<RespRow>(
              `insert into announcement_responses (school_id, announcement_id, student_id, guardian_id, response, responded_at)
               values (app.school_id(), $1, $2, $3, $4, $5)
               on conflict (announcement_id, student_id) do update
                 set response = excluded.response, guardian_id = excluded.guardian_id, responded_at = excluded.responded_at
               returning announcement_id, student_id, guardian_id, response, responded_at`,
              [id, b.student_id, me.personId, b.response, deps.clock.now()],
            ),
          );
          return toResponse(u.rows[0]!);
        } catch (err) {
          if ((err as { code?: string }).code === '42501') throw forbidden('You can only reply for your own child', 'not_your_child');
          throw err;
        }
      }),
    );
  });

  return r;
}
