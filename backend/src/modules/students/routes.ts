import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps } from '../../context.ts';
import { notFound } from '../../http/errors.ts';
import {
  asCaller, decodeCursor, idParam, isoDate, money, pageQuery, paginate, query, uuid, type Schemas,
} from '../../http/helpers.ts';
import { gradeBandFor, num, runningGrade, studentRef, visibleStudent, type GradeBandRange } from '../shared.ts';

const RATE = `(select round(100.0 * count(*) filter (where a.status in ('present', 'late')) / nullif(count(*), 0), 1)
                 from attendance_records a where a.student_id = p.id)`;
const GUARDIAN_NAMES = `case when app.role() = 'admin' then (
  select coalesce(array_agg(g.full_name order by gs.is_primary_contact desc, g.full_name), '{}')
    from guardian_student gs join people g on g.id = gs.guardian_id where gs.student_id = p.id) end`;
const SECTION = `left join lateral (
    select cs.id, cs.name, cs.grade_level from enrollments e
    join class_sections cs on cs.id = e.class_section_id
    where e.student_id = p.id and e.status = 'active' order by cs.name limit 1) cs on true`;

export function studentRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();

  r.get('/students', async (c) => {
    const q = query(
      c,
      pageQuery.extend({ q: z.string().max(100).optional(), class_section_id: uuid.optional(), grade_level: z.string().max(20).optional() }),
    );
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps, c, async (tx): Promise<Schemas['StudentPage']> => {
        const params: unknown[] = [q.limit + 1];
        const where = [`p.role = 'student'`];
        const add = (sql: string, v: unknown) => {
          params.push(v);
          where.push(sql.replace('?', `$${params.length}`));
        };
        if (q.q) add('strpos(lower(p.full_name), lower(?)) > 0', q.q);
        if (q.class_section_id)
          add(`exists (select 1 from enrollments e where e.student_id = p.id and e.class_section_id = ? and e.status = 'active')`, q.class_section_id);
        if (q.grade_level)
          add(`exists (select 1 from enrollments e join class_sections s on s.id = e.class_section_id
                        where e.student_id = p.id and e.status = 'active' and s.grade_level = ?)`, q.grade_level);
        if (cur) {
          params.push(cur.t, cur.id);
          where.push(`(p.full_name, p.id) > ($${params.length - 1}, $${params.length}::uuid)`);
        }
        const rows = await tx.query<{ id: string; full_name: string; section_id: string | null; section_name: string | null; grade_level: string | null; rate: string | null; gnames: string[] | null }>(
          `select p.id, p.full_name, cs.id as section_id, cs.name as section_name, cs.grade_level, ${RATE} as rate, ${GUARDIAN_NAMES} as gnames
             from people p ${SECTION}
            where ${where.join(' and ')}
            order by p.full_name, p.id limit $1`,
          params,
        );
        const page = paginate(rows.rows, q.limit, (s) => s.full_name);
        return {
          items: page.items.map((s) => ({
            ...studentRef(s),
            ...(s.grade_level ? { grade_level: s.grade_level } : {}),
            attendance_rate_pct: num(s.rate),
            ...(s.gnames ? { guardian_names: s.gnames } : {}),
          })),
          next_cursor: page.next_cursor,
        };
      }),
    );
  });

  r.get('/students/:id', async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps, c, async (tx, me): Promise<Schemas['StudentDetail']> => {
        await visibleStudent(tx, id, 'student_detail');
        const s = await tx.query<{ id: string; full_name: string; section_id: string | null; section_name: string | null; grade_level: string | null; rate: string | null }>(
          `select p.id, p.full_name, cs.id as section_id, cs.name as section_name, cs.grade_level, ${RATE} as rate
             from people p ${SECTION} where p.id = $1`,
          [id],
        );
        const row = s.rows[0]!;
        const out: Schemas['StudentDetail'] = {
          ...studentRef(row),
          ...(row.grade_level ? { grade_level: row.grade_level } : {}),
          attendance_rate_pct: num(row.rate),
        };
        if (me.role === 'admin' || me.role === 'teacher') {
          const g = await tx.query<{ id: string; full_name: string; role: Schemas['Role']; relationship: string; is_primary_contact: boolean; phone: string | null; email: string | null }>(
            `select g.id, g.full_name, g.role, gs.relationship, gs.is_primary_contact, pc.phone, pc.email
               from guardian_student gs join people g on g.id = gs.guardian_id
               left join person_contacts pc on pc.person_id = g.id
              where gs.student_id = $1 order by gs.is_primary_contact desc, g.full_name`,
            [id],
          );
          out.guardians = g.rows.map((x) => ({
            guardian: {
              id: x.id, full_name: x.full_name, role: x.role,
              ...(me.role === 'admin' && (x.phone || x.email) ? { contact: { ...(x.phone ? { phone: x.phone } : {}), ...(x.email ? { email: x.email } : {}) } } : {}),
            },
            relationship: x.relationship,
            is_primary_contact: x.is_primary_contact,
          }));
        }
        if (me.role === 'admin') {
          const e = await tx.query<Schemas['Enrollment']>(
            `select e.id, e.student_id, e.class_section_id, cs.name as class_section_name, t.name as term_name, e.status
               from enrollments e join class_sections cs on cs.id = e.class_section_id join terms t on t.id = cs.term_id
              where e.student_id = $1 order by t.starts_on desc, cs.name`,
            [id],
          );
          out.enrollments = e.rows;
        }
        return out;
      }),
    );
  });

  r.get('/students/:id/summary', async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps, c, async (tx): Promise<Schemas['StudentSummary']> => {
        try {
          const out = await tx.query<{ s: Schemas['StudentSummary'] & { balance: number | null; pending_payments: number | null } }>(
            'select student_summary($1) as s',
            [id],
          );
          const fn = out.rows[0]!.s;
          // The SQL function speaks in JSON numbers; money leaves the API as a decimal string.
          return {
            ...fn,
            balance: fn.balance == null ? null : money(fn.balance),
            pending_payments: fn.pending_payments == null ? null : money(fn.pending_payments),
          };
        } catch (err) {
          // The function refuses students the caller cannot see; to the client that is "not found".
          if ((err as { code?: string }).code === '42501') throw notFound('Student');
          throw err;
        }
      }),
    );
  });

  r.get('/students/:id/attendance', async (c) => {
    const id = idParam(c);
    const q = query(c, z.object({ from: isoDate.optional(), to: isoDate.optional() }));
    return c.json(
      await asCaller(deps, c, async (tx) => {
        await visibleStudent(tx, id, 'student_attendance');
        const rows = await tx.query<{
          id: string; student_id: string; class_section_id: string; period_id: string | null;
          period_date: string; status: Schemas['AttendanceStatus']; note: string | null; marked_by: string; marked_at: Date;
        }>(
          `select id, student_id, class_section_id, period_id, period_date, status, note, marked_by, marked_at
             from attendance_records
            where student_id = $1 and ($2::date is null or period_date >= $2) and ($3::date is null or period_date <= $3)
            order by period_date desc, marked_at desc`,
          [id, q.from ?? null, q.to ?? null],
        );
        const items: Schemas['AttendanceRecord'][] = rows.rows.map((a) => ({
          ...a, marked_at: a.marked_at.toISOString(),
          ...(a.note ? { note: a.note } : { note: null }),
          period_id: a.period_id,
        }));
        return { items };
      }),
    );
  });

  r.get('/students/:id/grades', async (c) => {
    const id = idParam(c);
    const q = query(c, z.object({ term_id: uuid.optional() }));
    return c.json(
      await asCaller(deps, c, async (tx) => {
        await visibleStudent(tx, id, 'student_grades');
        const rows = await tx.query<{
          class_section_id: string; subject: string; id: string; title: string; weight: string; max_score: string;
          due_date: string | null; score: string | null; comment: string | null;
        }>(
          `select a.class_section_id, a.subject, a.id, a.title, a.weight, a.max_score, a.due_date, g.score, g.comment
             from assessments a
             join class_sections cs on cs.id = a.class_section_id
             join terms t on t.id = cs.term_id
             join enrollments e on e.class_section_id = a.class_section_id and e.student_id = $1
             left join grades g on g.assessment_id = a.id and g.student_id = $1
            where ($2::uuid is null and not t.closed) or cs.term_id = $2
            order by a.class_section_id, a.subject, a.due_date nulls last, a.title`,
          [id, q.term_id ?? null],
        );
        const groups = new Map<string, Schemas['SubjectGrades']>();
        const numeric = new Map<string, { score: number | null; max_score: number; weight: number }[]>();
        for (const x of rows.rows) {
          const key = `${x.class_section_id}|${x.subject}`;
          if (!groups.has(key)) groups.set(key, { class_section_id: x.class_section_id, subject: x.subject, running_grade: null, grade_band: null, assessments: [] });
          const item = { score: num(x.score), max_score: Number(x.max_score), weight: Number(x.weight) };
          numeric.set(key, [...(numeric.get(key) ?? []), item]);
          groups.get(key)!.assessments!.push({
            id: x.id, subject: x.subject, title: x.title, weight: item.weight, max_score: item.max_score,
            due_date: x.due_date, score: item.score, comment: x.comment,
          });
        }
        const bandRows = await tx.query<{ label: string; min_score: string; max_score: string }>(
          'select label, min_score, max_score from grade_bands',
        );
        const bands: GradeBandRange[] = bandRows.rows.map((b) => ({ label: b.label, min_score: Number(b.min_score), max_score: Number(b.max_score) }));
        for (const [key, g] of groups) {
          g.running_grade = runningGrade(numeric.get(key)!);
          g.grade_band = gradeBandFor(g.running_grade, bands);
        }
        return { subjects: [...groups.values()] };
      }),
    );
  });

  return r;
}
