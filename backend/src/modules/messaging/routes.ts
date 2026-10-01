import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps, Tx } from '../../context.ts';
import { AppError, forbidden, notFound } from '../../http/errors.ts';
import { asCaller, body, decodeCursor, idParam, pageQuery, paginate, query, uuid, type Schemas } from '../../http/helpers.ts';
import { personRef, studentRef } from '../shared.ts';

interface ThreadRow {
  id: string; student_id: string; student_name: string; teacher_id: string; teacher_name: string;
  guardian_id: string; guardian_name: string;
  m_id: string | null; m_sender: string | null; m_body: string | null; m_at: Date | null; unread: number;
}

const toThread = (t: ThreadRow): Schemas['Thread'] => ({
  id: t.id,
  student: studentRef({ id: t.student_id, full_name: t.student_name }),
  teacher: personRef({ id: t.teacher_id, full_name: t.teacher_name, role: 'teacher' }),
  guardian: personRef({ id: t.guardian_id, full_name: t.guardian_name, role: 'guardian' }),
  ...(t.m_id && t.m_sender && t.m_body && t.m_at
    ? { last_message: { id: t.m_id, thread_id: t.id, sender_id: t.m_sender, body: t.m_body, created_at: t.m_at.toISOString() } }
    : {}),
  unread: t.unread,
});

/** Each thread with its newest message and how many messages from the other side the caller has not read. */
const THREAD_SELECT = `
  select t.id, t.student_id, st.full_name as student_name, t.teacher_id, te.full_name as teacher_name,
         t.guardian_id, g.full_name as guardian_name,
         lm.id as m_id, lm.sender_id as m_sender, lm.body as m_body, lm.created_at as m_at,
         case when app.role() = 'admin' then 0 else (select count(*)::int from messages m
           where m.thread_id = t.id and m.sender_id <> app.person_id()
             and m.created_at > coalesce((select tr.last_read_at from thread_reads tr
                                           where tr.thread_id = t.id and tr.person_id = app.person_id()), '-infinity'::timestamptz)) end as unread
    from message_threads t
    join people st on st.id = t.student_id
    join people te on te.id = t.teacher_id
    join people g on g.id = t.guardian_id
    left join lateral (select m.id, m.sender_id, m.body, m.created_at from messages m
                        where m.thread_id = t.id order by m.created_at desc, m.id desc limit 1) lm on true`;

async function threadById(tx: Tx, id: string): Promise<Schemas['Thread']> {
  const r = await tx.query<ThreadRow>(`${THREAD_SELECT} where t.id = $1`, [id]);
  if (!r.rows[0]) throw notFound('Thread');
  return toThread(r.rows[0]);
}

export function messagingRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();

  r.get('/threads', async (c) => {
    const q = query(c, z.object({ student_id: uuid.optional() }));
    return c.json({
      items: await asCaller(deps, c, async (tx) => {
        const rows = await tx.query<ThreadRow>(
          `${THREAD_SELECT} where ($1::uuid is null or t.student_id = $1)
            order by coalesce(lm.created_at, t.created_at) desc, t.id`,
          [q.student_id ?? null],
        );
        return rows.rows.map(toThread);
      }),
    });
  });

  /**
   * A thread is always about one child the two people share; never a free-floating DM.
   * The database enforces "shared" (the insert policy), this route just picks the sides.
   */
  r.post('/threads', async (c) => {
    const b = await body(c, z.object({ student_id: uuid, other_party_id: uuid }));
    const { thread, created } = await asCaller(deps, c, async (tx, me) => {
      if (me.role !== 'teacher' && me.role !== 'guardian') throw forbidden('Only teachers and guardians can start a conversation');
      const teacherId = me.role === 'teacher' ? me.personId : b.other_party_id;
      const guardianId = me.role === 'guardian' ? me.personId : b.other_party_id;

      const existing = await tx.query<{ id: string }>(
        'select id from message_threads where student_id = $1 and teacher_id = $2 and guardian_id = $3',
        [b.student_id, teacherId, guardianId],
      );
      if (existing.rows[0]) return { thread: await threadById(tx, existing.rows[0].id), created: false };

      let id: string;
      try {
        const ins = await tx.attempt(() =>
          tx.query<{ id: string }>(
            `insert into message_threads (school_id, student_id, teacher_id, guardian_id)
             values (app.school_id(), $1, $2, $3) returning id`,
            [b.student_id, teacherId, guardianId],
          ),
        );
        id = ins.rows[0]!.id;
      } catch (err) {
        const code = (err as { code?: string }).code;
        if (code === '42501' || code === '23503' || code === '23514')
          throw new AppError(403, 'not_a_shared_child', 'You can only message about a child you share with that person');
        throw err;
      }
      return { thread: await threadById(tx, id), created: true };
    });
    return c.json(thread, created ? 201 : 200);
  });

  r.get('/threads/:id/messages', async (c) => {
    const id = idParam(c);
    const q = query(c, pageQuery);
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps, c, async (tx) => {
        await threadById(tx, id); // 404 unless the caller may see it
        const params: unknown[] = [id, q.limit + 1];
        let cursorSql = '';
        if (cur) {
          params.push(cur.t, cur.id);
          cursorSql = `and (created_at, id) > ($3::timestamptz, $4::uuid)`;
        }
        const rows = await tx.query<{ id: string; thread_id: string; sender_id: string; body: string; created_at: Date }>(
          `select id, thread_id, sender_id, body, created_at from messages
            where thread_id = $1 ${cursorSql} order by created_at, id limit $2`,
          params,
        );
        const page = paginate(rows.rows, q.limit, (m) => m.created_at.toISOString());
        return {
          items: page.items.map((m): Schemas['Message'] => ({ ...m, created_at: m.created_at.toISOString() })),
          next_cursor: page.next_cursor,
        };
      }),
    );
  });

  r.post('/threads/:id/messages', async (c) => {
    const id = idParam(c);
    const b = await body(c, z.object({ body: z.string().trim().min(1).max(5000) }));
    const out = await asCaller(deps, c, async (tx, me) => {
      await threadById(tx, id);
      try {
        const m = await tx.attempt(() =>
          tx.query<{ id: string; thread_id: string; sender_id: string; body: string; created_at: Date }>(
            `insert into messages (school_id, thread_id, sender_id, body, created_at) values (app.school_id(), $1, $2, $3, $4)
             returning id, thread_id, sender_id, body, created_at`,
            [id, me.personId, b.body, deps.clock.now()],
          ),
        );
        const row = m.rows[0]!;
        // Sending implies having read everything so far.
        await tx.query(
          `insert into thread_reads (thread_id, person_id, last_read_at) values ($1, $2, $3)
           on conflict (thread_id, person_id) do update set last_read_at = excluded.last_read_at`,
          [id, me.personId, row.created_at],
        );
        return { ...row, created_at: row.created_at.toISOString() } satisfies Schemas['Message'];
      } catch (err) {
        // Visible but not writable: an administrator auditing a thread.
        if ((err as { code?: string }).code === '42501') throw forbidden('Only the two people in this conversation can send messages', 'not_a_participant');
        throw err;
      }
    });
    return c.json(out, 201);
  });

  r.post('/threads/:id/read', async (c) => {
    const id = idParam(c);
    await asCaller(deps, c, async (tx, me) => {
      await threadById(tx, id);
      if (me.role === 'admin') return; // auditors have no read state
      await tx.query(
        `insert into thread_reads (thread_id, person_id, last_read_at) values ($1, $2, $3)
         on conflict (thread_id, person_id) do update set last_read_at = excluded.last_read_at`,
        [id, me.personId, deps.clock.now()],
      );
    });
    return c.body(null, 204);
  });

  return r;
}
