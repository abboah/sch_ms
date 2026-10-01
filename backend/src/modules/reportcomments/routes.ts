import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps, Tx } from '../../context.ts';
import { notFound } from '../../http/errors.ts';
import { asCaller, body, idParam, query, uuid, type Schemas } from '../../http/helpers.ts';
import { requireRole } from '../../http/middleware.ts';
import { personRef, studentRef, visibleStudent } from '../shared.ts';

async function visibleSection(tx: Tx, id: string): Promise<{ id: string; term_closed: boolean }> {
  const r = await tx.query<{ id: string; term_closed: boolean }>(
    `select cs.id, t.closed as term_closed from class_sections cs join terms t on t.id = cs.term_id where cs.id = $1`,
    [id],
  );
  if (!r.rows[0]) throw notFound('Class section');
  return r.rows[0];
}

export function reportCommentRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();
  const staff = requireRole('teacher', 'admin');
  const teacher = requireRole('teacher');
  const parentOrAdmin = requireRole('admin', 'guardian');

  /** One subject's comments for every pupil in a section: the roster plus whatever has been drafted. */
  r.get('/class_sections/:id/comments', staff, async (c) => {
    const id = idParam(c);
    const q = query(c, z.object({ subject: z.string().min(1).max(60) }));
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const section = await visibleSection(tx, id);
        const students = await tx.query<{ id: string; full_name: string }>(
          `select p.id, p.full_name from enrollments e join people p on p.id = e.student_id
            where e.class_section_id = $1 and e.status = 'active' order by p.full_name`,
          [id],
        );
        const existing = await tx.query<{ student_id: string; body: string; updated_at: Date }>(
          `select student_id, body, updated_at from report_comments where class_section_id = $1 and subject = $2`,
          [id, q.subject],
        );
        const byStudent = new Map(existing.rows.map((x) => [x.student_id, x]));
        return {
          class_section_id: id,
          subject: q.subject,
          term_closed: section.term_closed,
          items: students.rows.map((s) => ({
            student: studentRef(s),
            body: byStudent.get(s.id)?.body ?? null,
            updated_at: byStudent.get(s.id)?.updated_at.toISOString() ?? null,
          })),
        };
      }),
    );
  });

  /** Batch upsert, like the gradebook's score grid: one bad row never loses the rest of the class. */
  r.patch('/class_sections/:id/comments', teacher, async (c) => {
    const id = idParam(c);
    const b = await body(
      c,
      z.object({
        subject: z.string().min(1).max(60),
        comments: z.array(z.object({ student_id: uuid, body: z.string().max(2000) })).min(1).max(200),
      }),
    );
    return c.json(
      await asCaller(deps, c, async (tx, me): Promise<Schemas['BatchResult']> => {
        const results: NonNullable<Schemas['BatchResult']['results']> = [];
        let applied = 0;
        let rejected = 0;
        for (const x of b.comments) {
          try {
            await tx.attempt(() =>
              tx.query(
                `insert into report_comments (school_id, student_id, class_section_id, subject, teacher_id, body)
                 values (app.school_id(), $1, $2, $3, $4, $5)
                 on conflict (student_id, class_section_id, subject) do update
                   set body = excluded.body, updated_at = $6, teacher_id = $4`,
                [x.student_id, id, b.subject, me.personId, x.body, deps.clock.now()],
              ),
            );
            applied++;
            results.push({ student_id: x.student_id, outcome: 'applied' });
          } catch (err) {
            const code = (err as { code?: string }).code;
            if (!['42501', '23514', '23503'].includes(code ?? '')) throw err;
            rejected++;
            results.push({
              student_id: x.student_id,
              outcome: 'rejected',
              code: code === '42501' ? 'not_enrolled' : 'unknown_student',
              message: code === '42501' ? 'This student is not enrolled in the section, or the term is closed' : 'No such student',
            });
          }
        }
        return { applied, rejected, results };
      }),
    );
  });

  /** A guardian's own child, or admin: only comments from closed (issued) terms, the database decides which. */
  r.get('/students/:id/report_comments', parentOrAdmin, async (c) => {
    const id = idParam(c);
    return c.json({
      items: await asCaller(deps, c, async (tx) => {
        await visibleStudent(tx, id, 'student_report_comments');
        const rows = await tx.query<{
          class_section_id: string; subject: string; body: string; updated_at: Date;
          teacher_id: string; teacher_name: string;
        }>(
          `select rc.class_section_id, rc.subject, rc.body, rc.updated_at, rc.teacher_id, p.full_name as teacher_name
             from report_comments rc join people p on p.id = rc.teacher_id
            where rc.student_id = $1 order by rc.subject`,
          [id],
        );
        return rows.rows.map((x) => ({
          class_section_id: x.class_section_id,
          subject: x.subject,
          body: x.body,
          updated_at: x.updated_at.toISOString(),
          teacher: personRef({ id: x.teacher_id, full_name: x.teacher_name, role: 'teacher' }),
        }));
      }),
    });
  });

  return r;
}
