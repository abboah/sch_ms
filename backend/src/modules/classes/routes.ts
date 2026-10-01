import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps, Tx } from '../../context.ts';
import { conflict, notFound } from '../../http/errors.ts';
import { asCaller, body, idParam, isoDate, query, uuid, type Schemas } from '../../http/helpers.ts';
import { requireRole } from '../../http/middleware.ts';
import { hhmm, num, personRef, studentRef } from '../shared.ts';

const termInput = z.object({
  name: z.string().min(1).max(80),
  starts_on: isoDate,
  ends_on: isoDate,
  closed: z.boolean(),
});

const sectionInput = z.object({
  name: z.string().min(1).max(40),
  grade_level: z.string().min(1).max(20),
  term_id: uuid,
  homeroom_teacher_id: uuid.nullable(),
});

const periodInput = z.object({
  subject: z.string().min(1).max(60),
  teacher_id: uuid,
  weekday: z.number().int().min(1).max(7),
  starts_at: z.string().regex(/^\d{2}:\d{2}$/),
  ends_at: z.string().regex(/^\d{2}:\d{2}$/),
});

interface SectionRow {
  id: string; name: string; grade_level: string; term_id: string;
  homeroom_id: string | null; homeroom_name: string | null; subject: string | null;
}

const SECTION_SELECT = `
  select cs.id, cs.name, cs.grade_level, cs.term_id, h.id as homeroom_id, h.full_name as homeroom_name,
         (select string_agg(st.subject, ', ' order by st.subject) from section_teachers st
           where st.section_id = cs.id and st.teacher_id = app.person_id()) as subject
    from class_sections cs left join people h on h.id = cs.homeroom_teacher_id`;

const toSection = (s: SectionRow): Schemas['ClassSection'] => ({
  id: s.id,
  name: s.name,
  grade_level: s.grade_level,
  term_id: s.term_id,
  ...(s.homeroom_id && s.homeroom_name ? { homeroom_teacher: personRef({ id: s.homeroom_id, full_name: s.homeroom_name, role: 'teacher' }) } : {}),
  ...(s.subject ? { subject: s.subject } : {}),
});

async function sectionById(tx: Tx, id: string): Promise<Schemas['ClassSection']> {
  const r = await tx.query<SectionRow>(`${SECTION_SELECT} where cs.id = $1`, [id]);
  if (!r.rows[0]) throw notFound('Class section');
  return toSection(r.rows[0]);
}

export function classRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();
  const admin = requireRole('admin');

  // ---- terms ---------------------------------------------------------------
  r.get('/terms', async (c) =>
    c.json({
      items: await asCaller(deps, c, async (tx) => {
        const t = await tx.query<Schemas['Term']>('select id, name, starts_on, ends_on, closed from terms order by starts_on desc');
        return t.rows;
      }),
    }),
  );

  r.post('/terms', admin, async (c) => {
    const b = await body(c, termInput.partial({ closed: true }));
    const out = await asCaller(deps, c, async (tx, me) => {
      const t = await tx.query<Schemas['Term']>(
        `insert into terms (school_id, name, starts_on, ends_on, closed) values ($1, $2, $3, $4, $5)
         returning id, name, starts_on, ends_on, closed`,
        [me.schoolId, b.name, b.starts_on, b.ends_on, b.closed ?? false],
      );
      return t.rows[0]!;
    });
    return c.json(out, 201);
  });

  r.patch('/terms/:id', admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, termInput.partial());
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const t = await tx.query<Schemas['Term']>(
          `update terms set name = coalesce($2, name), starts_on = coalesce($3::date, starts_on),
                            ends_on = coalesce($4::date, ends_on), closed = coalesce($5, closed)
            where id = $1 returning id, name, starts_on, ends_on, closed`,
          [id, b.name ?? null, b.starts_on ?? null, b.ends_on ?? null, b.closed ?? null],
        );
        if (!t.rows[0]) throw notFound('Term');
        return t.rows[0];
      }),
    );
  });

  // ---- sections ------------------------------------------------------------
  r.get('/class_sections', async (c) => {
    const q = query(c, z.object({ term_id: uuid.optional() }));
    return c.json({
      items: await asCaller(deps, c, async (tx) => {
        const rows = await tx.query<SectionRow>(
          `${SECTION_SELECT} where ($1::uuid is null or cs.term_id = $1) order by cs.grade_level, cs.name`,
          [q.term_id ?? null],
        );
        return rows.rows.map(toSection);
      }),
    });
  });

  r.post('/class_sections', admin, async (c) => {
    const b = await body(c, sectionInput.partial({ homeroom_teacher_id: true }));
    const out = await asCaller(deps, c, async (tx, me) => {
      const ins = await tx.query<{ id: string }>(
        `insert into class_sections (school_id, term_id, name, grade_level, homeroom_teacher_id)
         values ($1, $2, $3, $4, $5) returning id`,
        [me.schoolId, b.term_id, b.name, b.grade_level, b.homeroom_teacher_id ?? null],
      );
      return sectionById(tx, ins.rows[0]!.id);
    });
    return c.json(out, 201);
  });

  r.get('/class_sections/:id', async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps, c, async (tx): Promise<Schemas['ClassSectionDetail']> => {
        const section = await sectionById(tx, id);
        const teachers = await tx.query<{ id: string; full_name: string; subject: string }>(
          `select p.id, p.full_name, st.subject from section_teachers st join people p on p.id = st.teacher_id
            where st.section_id = $1 order by st.subject, p.full_name`,
          [id],
        );
        const roster = await tx.query<{ id: string; full_name: string; rate: string | null }>(
          `select p.id, p.full_name,
                  (select round(100.0 * count(*) filter (where a.status in ('present', 'late')) / nullif(count(*), 0), 1)
                     from attendance_records a where a.student_id = p.id and a.class_section_id = $1) as rate
             from enrollments e join people p on p.id = e.student_id
            where e.class_section_id = $1 and e.status = 'active' order by p.full_name`,
          [id],
        );
        const overall = await tx.query<{ rate: string | null }>(
          `select round(100.0 * count(*) filter (where status in ('present', 'late')) / nullif(count(*), 0), 1) as rate
             from attendance_records where class_section_id = $1`,
          [id],
        );
        return {
          ...section,
          teachers: teachers.rows.map((t) => ({ person: personRef({ ...t, role: 'teacher' }), subject: t.subject })),
          roster: roster.rows.map((s) => ({ ...studentRef({ ...s, section_id: id, section_name: section.name }), attendance_rate_pct: num(s.rate) })),
          attendance_rate_pct: num(overall.rows[0]?.rate),
        };
      }),
    );
  });

  r.patch('/class_sections/:id', admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, sectionInput.partial());
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const hasHomeroom = 'homeroom_teacher_id' in b;
        const u = await tx.query(
          `update class_sections set name = coalesce($2, name), grade_level = coalesce($3, grade_level),
                  term_id = coalesce($4::uuid, term_id),
                  homeroom_teacher_id = case when $6 then $5::uuid else homeroom_teacher_id end
            where id = $1`,
          [id, b.name ?? null, b.grade_level ?? null, b.term_id ?? null, b.homeroom_teacher_id ?? null, hasHomeroom],
        );
        if (u.rowCount === 0) throw notFound('Class section');
        return sectionById(tx, id);
      }),
    );
  });

  // ---- timetable -----------------------------------------------------------
  const periods = async (tx: Tx, sectionId: string): Promise<Schemas['Period'][]> => {
    const rows = await tx.query<{ id: string; subject: string; weekday: number; starts_at: string; ends_at: string; tid: string; tname: string }>(
      `select p.id, p.subject, p.weekday, p.starts_at, p.ends_at, t.id as tid, t.full_name as tname
         from periods p join people t on t.id = p.teacher_id
        where p.class_section_id = $1 order by p.weekday, p.starts_at`,
      [sectionId],
    );
    return rows.rows.map((p) => ({
      id: p.id, subject: p.subject, weekday: p.weekday, starts_at: hhmm(p.starts_at), ends_at: hhmm(p.ends_at),
      teacher: personRef({ id: p.tid, full_name: p.tname, role: 'teacher' }),
    }));
  };

  r.get('/class_sections/:id/periods', async (c) => {
    const id = idParam(c);
    return c.json({
      items: await asCaller(deps, c, async (tx) => {
        await sectionById(tx, id); // 404 if the caller cannot see the section
        return periods(tx, id);
      }),
    });
  });

  /**
   * Replace the timetable by diffing, not delete-and-reinsert: periods that already have
   * attendance recorded against them cannot be removed, and their ids must stay stable.
   */
  r.put('/class_sections/:id/periods', admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, z.array(periodInput).max(100));
    return c.json({
      items: await asCaller(deps, c, async (tx, me) => {
        await sectionById(tx, id);
        const existing = await tx.query<{ id: string; teacher_id: string; subject: string; weekday: number; starts_at: string }>(
          'select id, teacher_id, subject, weekday, starts_at from periods where class_section_id = $1',
          [id],
        );
        const key = (x: { teacher_id: string; subject: string; weekday: number; starts_at: string }) =>
          `${x.teacher_id}|${x.subject}|${x.weekday}|${hhmm(x.starts_at)}`;
        const wanted = new Map(b.map((p) => [key({ ...p }), p]));
        const have = new Map(existing.rows.map((p) => [key(p), p.id]));

        for (const [k, p] of wanted) {
          if (have.has(k)) {
            await tx.query('update periods set ends_at = $2 where id = $1', [have.get(k), p.ends_at]);
          } else {
            await tx.query(
              `insert into periods (school_id, class_section_id, teacher_id, subject, weekday, starts_at, ends_at)
               values ($1, $2, $3, $4, $5, $6, $7)`,
              [me.schoolId, id, p.teacher_id, p.subject, p.weekday, p.starts_at, p.ends_at],
            );
          }
        }
        for (const [k, pid] of have) {
          if (wanted.has(k)) continue;
          try {
            await tx.attempt(() => tx.query('delete from periods where id = $1', [pid]));
          } catch (err) {
            if ((err as { code?: string }).code === '23503')
              throw conflict('A period with recorded attendance cannot be removed', 'period_in_use');
            throw err;
          }
        }
        return periods(tx, id);
      }),
    });
  });

  // ---- enrollments ---------------------------------------------------------
  r.post('/enrollments', admin, async (c) => {
    const b = await body(c, z.object({ student_id: uuid, class_section_id: uuid }));
    const out = await asCaller(deps, c, async (tx, me) => {
      const e = await tx.query<Schemas['Enrollment']>(
        `insert into enrollments (school_id, student_id, class_section_id, status) values ($1, $2, $3, 'active')
         on conflict (student_id, class_section_id) do update set status = 'active' where enrollments.status <> 'active'
         returning id, student_id, class_section_id, status`,
        [me.schoolId, b.student_id, b.class_section_id],
      );
      if (!e.rows[0]) throw conflict('That student is already enrolled in this section', 'already_enrolled');
      return e.rows[0];
    });
    return c.json(out, 201);
  });

  r.delete('/enrollments/:id', admin, async (c) => {
    const id = idParam(c);
    await asCaller(deps, c, async (tx) => {
      const e = await tx.query(`update enrollments set status = 'withdrawn' where id = $1`, [id]);
      if (e.rowCount === 0) throw notFound('Enrollment');
    });
    return c.body(null, 204);
  });

  /** Bulk-create students and enrol them in one section: the CSV-import path. Each row is a new
   *  person, so there is nothing per-row to partially reject (unlike scores or comments, which can
   *  legitimately conflict with a constraint); a malformed row fails the whole call, same as any
   *  other create endpoint here. */
  r.post('/class_sections/:id/students/import', admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, z.object({ students: z.array(z.object({ full_name: z.string().trim().min(1).max(120) })).min(1).max(300) }));
    const items = await asCaller(deps, c, async (tx, me) => {
      const out: Schemas['StudentRef'][] = [];
      for (const s of b.students) {
        const p = await tx.query<{ id: string }>(
          `insert into people (school_id, full_name, role) values ($1, $2, 'student') returning id`,
          [me.schoolId, s.full_name],
        );
        const studentId = p.rows[0]!.id;
        await tx.query(
          `insert into enrollments (school_id, student_id, class_section_id, status) values ($1, $2, $3, 'active')`,
          [me.schoolId, studentId, id],
        );
        out.push(studentRef({ id: studentId, full_name: s.full_name }));
      }
      return out;
    });
    return c.json({ items }, 201);
  });

  return r;
}
