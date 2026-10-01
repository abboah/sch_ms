import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps, Tx } from '../../context.ts';
import { AppError, notFound, unprocessable } from '../../http/errors.ts';
import { asCaller, body, idParam, isoDate, query, uuid, type Schemas } from '../../http/helpers.ts';
import { requireRole } from '../../http/middleware.ts';
import { gradeBandFor, runningGrade, studentRef, type GradeBandRange } from '../shared.ts';

const assessmentInput = z.object({
  subject: z.string().min(1).max(60),
  title: z.string().min(1).max(120),
  weight: z.number().gt(0).max(100),
  max_score: z.number().gt(0).max(100000),
  due_date: isoDate.nullable().optional(),
});

interface AssessmentRow {
  id: string; class_section_id: string; subject: string; title: string; weight: string; max_score: string; due_date: string | null;
}
const toAssessment = (a: AssessmentRow): Schemas['Assessment'] => ({
  id: a.id, subject: a.subject, title: a.title, weight: Number(a.weight), max_score: Number(a.max_score), due_date: a.due_date,
});

const termClosed = () => new AppError(403, 'term_closed', 'This term is closed; its gradebook can no longer be changed');

async function visibleSection(tx: Tx, id: string): Promise<{ id: string; term_closed: boolean }> {
  const r = await tx.query<{ id: string; term_closed: boolean }>(
    `select cs.id, t.closed as term_closed from class_sections cs join terms t on t.id = cs.term_id where cs.id = $1`,
    [id],
  );
  if (!r.rows[0]) throw notFound('Class section');
  return r.rows[0];
}

export function gradebookRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();
  const staff = requireRole('teacher', 'admin');
  const teacher = requireRole('teacher');

  /** The weights of one subject in one section are shares of a whole: they may not add up past 100. */
  async function weightTotal(tx: Tx, sectionId: string, subject: string, excludeId: string | null): Promise<number> {
    const t = await tx.query<{ total: string }>(
      `select coalesce(sum(weight), 0) as total from assessments
        where class_section_id = $1 and subject = $2 and ($3::uuid is null or id <> $3)`,
      [sectionId, subject, excludeId],
    );
    return Number(t.rows[0]?.total ?? 0);
  }

  r.get('/class_sections/:id/gradebook', staff, async (c) => {
    const id = idParam(c);
    const q = query(c, z.object({ subject: z.string().max(60).optional() }));
    return c.json(
      await asCaller(deps, c, async (tx): Promise<Schemas['Gradebook']> => {
        const section = await visibleSection(tx, id);
        const assessments = await tx.query<AssessmentRow>(
          `select id, class_section_id, subject, title, weight, max_score, due_date from assessments
            where class_section_id = $1 and ($2::text is null or subject = $2)
            order by due_date nulls last, title`,
          [id, q.subject ?? null],
        );
        const students = await tx.query<{ id: string; full_name: string }>(
          `select p.id, p.full_name from enrollments e join people p on p.id = e.student_id
            where e.class_section_id = $1 and e.status = 'active' order by p.full_name`,
          [id],
        );
        const grades = await tx.query<{ assessment_id: string; student_id: string; score: string | null }>(
          `select g.assessment_id, g.student_id, g.score from grades g
             join assessments a on a.id = g.assessment_id
            where a.class_section_id = $1 and ($2::text is null or a.subject = $2)`,
          [id, q.subject ?? null],
        );
        const byStudent = new Map<string, Map<string, number | null>>();
        for (const g of grades.rows) {
          if (!byStudent.has(g.student_id)) byStudent.set(g.student_id, new Map());
          byStudent.get(g.student_id)!.set(g.assessment_id, g.score == null ? null : Number(g.score));
        }
        const meta = assessments.rows.map((a) => ({ id: a.id, weight: Number(a.weight), max_score: Number(a.max_score) }));
        const bandRows = await tx.query<{ label: string; min_score: string; max_score: string }>(
          'select label, min_score, max_score from grade_bands',
        );
        const bands: GradeBandRange[] = bandRows.rows.map((b) => ({ label: b.label, min_score: Number(b.min_score), max_score: Number(b.max_score) }));
        return {
          class_section_id: id,
          term_closed: section.term_closed,
          assessments: assessments.rows.map(toAssessment),
          rows: students.rows.map((s) => {
            const scores = byStudent.get(s.id) ?? new Map<string, number | null>();
            const running = runningGrade(meta.map((m) => ({ score: scores.get(m.id) ?? null, max_score: m.max_score, weight: m.weight })));
            return {
              student: studentRef(s),
              scores: Object.fromEntries(meta.map((m) => [m.id, scores.get(m.id) ?? null])),
              running_grade: running,
              grade_band: gradeBandFor(running, bands),
            };
          }),
        };
      }),
    );
  });

  r.post('/class_sections/:id/assessments', teacher, async (c) => {
    const id = idParam(c);
    const b = await body(c, assessmentInput);
    const out = await asCaller(deps, c, async (tx, me) => {
      if ((await visibleSection(tx, id)).term_closed) throw termClosed();
      if ((await weightTotal(tx, id, b.subject, null)) + b.weight > 100) {
        throw unprocessable('The weights for this subject would add up to more than 100%', 'weights_exceed_100');
      }
      const a = await tx.query<AssessmentRow>(
        `insert into assessments (school_id, class_section_id, subject, title, weight, max_score, due_date)
         values ($1, $2, $3, $4, $5, $6, $7)
         returning id, class_section_id, subject, title, weight, max_score, due_date`,
        [me.schoolId, id, b.subject, b.title, b.weight, b.max_score, b.due_date ?? null],
      );
      return toAssessment(a.rows[0]!);
    });
    return c.json(out, 201);
  });

  r.patch('/assessments/:id', teacher, async (c) => {
    const id = idParam(c);
    const b = await body(c, assessmentInput.partial());
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const cur = await tx.query<AssessmentRow & { term_closed: boolean }>(
          `select a.id, a.class_section_id, a.subject, a.title, a.weight, a.max_score, a.due_date, t.closed as term_closed
             from assessments a join class_sections cs on cs.id = a.class_section_id join terms t on t.id = cs.term_id
            where a.id = $1`,
          [id],
        );
        const a = cur.rows[0];
        if (!a) throw notFound('Assessment');
        if (a.term_closed) throw termClosed();
        const subject = b.subject ?? a.subject;
        const weight = b.weight ?? Number(a.weight);
        if ((await weightTotal(tx, a.class_section_id, subject, id)) + weight > 100) {
          throw unprocessable('The weights for this subject would add up to more than 100%', 'weights_exceed_100');
        }
        const u = await tx.query<AssessmentRow>(
          `update assessments set subject = $2, title = $3, weight = $4, max_score = $5,
                  due_date = case when $7 then $6::date else due_date end
            where id = $1 returning id, class_section_id, subject, title, weight, max_score, due_date`,
          [id, subject, b.title ?? a.title, weight, b.max_score ?? Number(a.max_score), b.due_date ?? null, 'due_date' in b],
        );
        if (!u.rows[0]) throw notFound('Assessment');
        return toAssessment(u.rows[0]);
      }),
    );
  });

  r.get('/assessments/:id/grades', staff, async (c) => {
    const id = idParam(c);
    return c.json({
      items: await asCaller(deps, c, async (tx) => {
        const a = await tx.query('select 1 from assessments where id = $1', [id]);
        if (a.rowCount === 0) throw notFound('Assessment');
        const rows = await tx.query<{ student_id: string; assessment_id: string; score: string | null; comment: string | null }>(
          'select student_id, assessment_id, score, comment from grades where assessment_id = $1',
          [id],
        );
        return rows.rows.map((g): Schemas['Grade'] => ({
          student_id: g.student_id, assessment_id: g.assessment_id, score: g.score == null ? null : Number(g.score), comment: g.comment,
        }));
      }),
    });
  });

  /** Batch upsert with per-entry outcomes, like the attendance register. Omitted field = keep, null = clear. */
  r.patch('/assessments/:id/grades', teacher, async (c) => {
    const id = idParam(c);
    const b = await body(
      c,
      z.object({
        grades: z
          .array(z.object({ student_id: uuid, score: z.number().min(0).nullable().optional(), comment: z.string().max(1000).nullable().optional() }))
          .min(1)
          .max(200),
      }),
    );
    return c.json(
      await asCaller(deps, c, async (tx): Promise<Schemas['BatchResult']> => {
        const a = await tx.query<{ term_closed: boolean }>(
          `select t.closed as term_closed from assessments a
             join class_sections cs on cs.id = a.class_section_id join terms t on t.id = cs.term_id where a.id = $1`,
          [id],
        );
        if (!a.rows[0]) throw notFound('Assessment');
        if (a.rows[0].term_closed) throw termClosed();

        const results: NonNullable<Schemas['BatchResult']['results']> = [];
        let applied = 0;
        let rejected = 0;
        for (const g of b.grades) {
          try {
            await tx.attempt(() =>
              tx.query(
                `insert into grades (school_id, assessment_id, student_id, score, comment)
                 values (app.school_id(), $1, $2, $3, $4)
                 on conflict (assessment_id, student_id) do update set
                   score = case when $5 then excluded.score else grades.score end,
                   comment = case when $6 then excluded.comment else grades.comment end,
                   updated_at = $7`,
                [id, g.student_id, g.score ?? null, g.comment ?? null, 'score' in g, 'comment' in g, deps.clock.now()],
              ),
            );
            applied++;
            results.push({ student_id: g.student_id, outcome: 'applied' });
          } catch (err) {
            const code = (err as { code?: string }).code;
            if (!['42501', '23514', '23503'].includes(code ?? '')) throw err;
            rejected++;
            results.push({
              student_id: g.student_id,
              outcome: 'rejected',
              code: code === '23514' ? 'score_out_of_range' : code === '42501' ? 'not_enrolled' : 'unknown_student',
              message:
                code === '23514' ? (err as Error).message
                : code === '42501' ? 'This student is not enrolled in the section'
                : 'No such student',
            });
          }
        }
        return { applied, rejected, results };
      }),
    );
  });

  return r;
}
