import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps } from '../../context.ts';
import { forbidden, notFound } from '../../http/errors.ts';
import { asCaller, body, idParam, isoDate, query, type Schemas } from '../../http/helpers.ts';
import { requireRole } from '../../http/middleware.ts';
import { personRef, visibleStudent } from '../shared.ts';

interface HwRow {
  id: string; class_section_id: string; subject: string | null; title: string; body: string | null; due_date: string;
  posted_by: string; poster_name: string | null;
}

/** The subject is the poster's subject in that section (homeroom work has none). */
const HW_SELECT = `
  select h.id, h.class_section_id, h.title, h.body, h.due_date, h.posted_by, p.full_name as poster_name,
         (select string_agg(st.subject, ', ' order by st.subject) from section_teachers st
           where st.section_id = h.class_section_id and st.teacher_id = h.posted_by and st.subject <> 'Homeroom') as subject
    from homework h left join people p on p.id = h.posted_by`;

const toHomework = (h: HwRow): Schemas['Homework'] => ({
  id: h.id,
  class_section_id: h.class_section_id,
  subject: h.subject,
  title: h.title,
  body: h.body,
  due_date: h.due_date,
  ...(h.poster_name ? { posted_by: personRef({ id: h.posted_by, full_name: h.poster_name, role: 'teacher' }) } : {}),
});

export function homeworkRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();

  r.get('/class_sections/:id/homework', requireRole('teacher', 'admin'), async (c) => {
    const id = idParam(c);
    return c.json({
      items: await asCaller(deps, c, async (tx) => {
        const s = await tx.query('select 1 from class_sections where id = $1', [id]);
        if (s.rowCount === 0) throw notFound('Class section');
        const rows = await tx.query<HwRow>(`${HW_SELECT} where h.class_section_id = $1 order by h.due_date desc, h.id`, [id]);
        return rows.rows.map(toHomework);
      }),
    });
  });

  r.post('/class_sections/:id/homework', requireRole('teacher'), async (c) => {
    const id = idParam(c);
    const b = await body(c, z.object({ title: z.string().trim().min(1).max(200), body: z.string().max(5000).optional(), due_date: isoDate }));
    const out = await asCaller(deps, c, async (tx, me) => {
      const s = await tx.query('select 1 from class_sections where id = $1', [id]);
      if (s.rowCount === 0) throw notFound('Class section');
      try {
        const ins = await tx.attempt(() =>
          tx.query<{ id: string }>(
            `insert into homework (school_id, class_section_id, title, body, due_date, posted_by, created_at)
             values (app.school_id(), $1, $2, $3, $4, $5, $6) returning id`,
            [id, b.title, b.body ?? null, b.due_date, me.personId, deps.clock.now()],
          ),
        );
        const rows = await tx.query<HwRow>(`${HW_SELECT} where h.id = $1`, [ins.rows[0]!.id]);
        return toHomework(rows.rows[0]!);
      } catch (err) {
        if ((err as { code?: string }).code === '42501') throw forbidden('You can only post homework to a class you teach, in an open term', 'cannot_post_here');
        throw err;
      }
    });
    return c.json(out, 201);
  });

  r.get('/students/:id/homework', async (c) => {
    const id = idParam(c);
    const q = query(c, z.object({ due_from: isoDate.optional() }));
    return c.json({
      items: await asCaller(deps, c, async (tx) => {
        await visibleStudent(tx, id, 'student_homework');
        const rows = await tx.query<HwRow>(
          `${HW_SELECT}
            where h.class_section_id in (select class_section_id from enrollments where student_id = $1 and status = 'active')
              and ($2::date is null or h.due_date >= $2)
            order by h.due_date, h.id`,
          [id, q.due_from ?? null],
        );
        return rows.rows.map(toHomework);
      }),
    });
  });

  return r;
}
