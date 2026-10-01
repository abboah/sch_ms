import { Hono, type Context } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps, Tx } from '../../context.ts';
import { AppError, forbidden, notFound } from '../../http/errors.ts';
import { asCaller, body, idParam, iso, isoDate, query, uuid, type Schemas } from '../../http/helpers.ts';
import { requireRole } from '../../http/middleware.ts';
import { hhmm, num, schoolTimezone, studentRef, todayIn } from '../shared.ts';

const status = z.enum(['present', 'late', 'absent', 'excused']);
const MAX_ENTRIES = 200;
/** A device clock can be wrong; never trust a mark time from the future. */
const CLOCK_SKEW_MS = 5 * 60 * 1000;

const submission = z.object({
  date: isoDate,
  period_id: uuid.nullable().optional(),
  entries: z
    .array(z.object({ student_id: uuid, status, note: z.string().max(500).optional(), marked_at: z.iso.datetime() }))
    .min(1)
    .max(MAX_ENTRIES),
});

/** Section the caller can see, with whether its term is closed. 404 if not visible. */
async function visibleSection(tx: Tx, id: string): Promise<{ id: string; name: string; term_closed: boolean }> {
  const r = await tx.query<{ id: string; name: string; term_closed: boolean }>(
    `select cs.id, cs.name, t.closed as term_closed from class_sections cs join terms t on t.id = cs.term_id where cs.id = $1`,
    [id],
  );
  if (!r.rows[0]) throw notFound('Class section');
  return r.rows[0];
}

const csvCell = (v: string | number | null): string => {
  const s = v == null ? '' : String(v);
  // Quote anything with separators, and neutralise spreadsheet formula injection.
  const safe = /^[=+\-@\t\r]/.test(s) ? `'${s}` : s;
  return /[",\n\r]/.test(safe) ? `"${safe.replace(/"/g, '""')}"` : safe;
};

export function attendanceRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();

  r.get('/class_sections/:id/attendance', requireRole('teacher', 'admin'), async (c) => {
    const id = idParam(c);
    const q = query(c, z.object({ date: isoDate, period_id: uuid.optional() }));
    return c.json(
      await asCaller(deps, c, async (tx): Promise<Schemas['Register']> => {
        const section = await visibleSection(tx, id);
        const rows = await tx.query<{ id: string; full_name: string; status: Schemas['AttendanceStatus'] | null; note: string | null; record_id: string | null }>(
          `select p.id, p.full_name, a.status, a.note, a.id as record_id
             from enrollments e
             join people p on p.id = e.student_id
             left join attendance_records a
               on a.student_id = p.id and a.class_section_id = e.class_section_id
              and a.period_date = $2 and a.period_id is not distinct from $3::uuid
            where e.class_section_id = $1 and e.status = 'active'
            order by p.full_name`,
          [id, q.date, q.period_id ?? null],
        );
        return {
          class_section_id: id,
          period_id: q.period_id ?? null,
          date: q.date,
          term_closed: section.term_closed,
          entries: rows.rows.map((x) => ({
            student: studentRef({ id: x.id, full_name: x.full_name }),
            status: x.status,
            note: x.note,
            record_id: x.record_id,
          })),
        };
      }),
    );
  });

  /**
   * Also the offline-sync endpoint. Each entry stands alone: the register is applied entry by
   * entry inside savepoints so one bad row (a student withdrawn while the device was offline)
   * cannot lose the rest. Upsert is last-write-wins on the device's `marked_at`, so a stale
   * queued write never overwrites a newer mark, and replaying a batch is harmless.
   */
  r.put('/class_sections/:id/attendance', requireRole('teacher', 'admin'), async (c) => {
    const id = idParam(c);
    const b = await body(c, submission);
    const now = deps.clock.now();
    return c.json(
      await asCaller(deps, c, async (tx, me): Promise<Schemas['RegisterResult']> => {
        const section = await visibleSection(tx, id);
        if (section.term_closed && me.role !== 'admin') {
          throw new AppError(403, 'term_closed', 'This term is closed; only an administrator can change its attendance');
        }
        const results: NonNullable<Schemas['BatchResult']['results']> = [];
        let applied = 0;
        let rejected = 0;

        for (const e of b.entries) {
          const markedAt = new Date(Math.min(new Date(e.marked_at).getTime(), now.getTime() + CLOCK_SKEW_MS));
          try {
            const out = await tx.attempt(() =>
              tx.query(
                `insert into attendance_records
                   (school_id, student_id, class_section_id, period_id, period_date, status, marked_by, note, marked_at)
                 values (app.school_id(), $1, $2, $3, $4, $5, app.person_id(), $6, $7)
                 on conflict (student_id, class_section_id, period_id, period_date) do update
                   set status = excluded.status, note = excluded.note,
                       marked_by = excluded.marked_by, marked_at = excluded.marked_at
                   where attendance_records.marked_at <= excluded.marked_at
                 returning id`,
                [e.student_id, id, b.period_id ?? null, b.date, e.status, e.note ?? null, markedAt],
              ),
            );
            if (out.rowCount > 0) {
              applied++;
              results.push({ student_id: e.student_id, outcome: 'applied' });
            } else {
              results.push({ student_id: e.student_id, outcome: 'stale', message: 'A newer mark already exists' });
            }
          } catch (err) {
            const code = (err as { code?: string }).code;
            rejected++;
            results.push({
              student_id: e.student_id,
              outcome: 'rejected',
              code: code === '42501' ? 'not_enrolled' : code === '23503' ? 'unknown_student' : code === '23514' ? 'invalid_student' : 'error',
              message:
                code === '42501' ? 'This student is not enrolled in the section'
                : code === '23503' ? 'No such student or period'
                : code === '23514' ? 'Not a student'
                : 'Could not be saved',
            });
            if (!['42501', '23503', '23514'].includes(code ?? '')) throw err; // unexpected: fail the whole request
          }
        }
        return { applied, rejected, results };
      }),
    );
  });

  r.patch('/attendance_records/:id', async (c) => {
    const id = idParam(c);
    const b = await body(c, z.object({ status: status.optional(), note: z.string().max(500).nullable().optional() }));
    return c.json(
      await asCaller(deps, c, async (tx, me): Promise<Schemas['AttendanceRecord']> => {
        const cur = await tx.query('select 1 from attendance_records where id = $1', [id]);
        if (cur.rowCount === 0) throw notFound('Attendance record');
        const u = await tx.query<{
          id: string; student_id: string; class_section_id: string; period_id: string | null;
          period_date: string; status: Schemas['AttendanceStatus']; note: string | null; marked_by: string; marked_at: Date;
        }>(
          `update attendance_records
              set status = coalesce($2::attendance_status, status),
                  note = case when $4 then $3 else note end,
                  marked_by = $5, marked_at = $6
            where id = $1
        returning id, student_id, class_section_id, period_id, period_date, status, note, marked_by, marked_at`,
          [id, b.status ?? null, b.note ?? null, 'note' in b, me.personId, deps.clock.now()],
        );
        // Visible but not updatable: a teacher editing a closed term.
        if (!u.rows[0]) throw forbidden('This term is closed; only an administrator can change it', 'term_closed');
        const row = u.rows[0];
        return { ...row, marked_at: row.marked_at.toISOString() };
      }),
    );
  });

  const reportQuery = z.object({ from: isoDate, to: isoDate, class_section_id: uuid.optional() });

  /** Per-pupil counts over a date range. Shared by the JSON and CSV routes. */
  const loadReport = (c: Context<AppEnv>): Promise<Schemas['AttendanceReport']> => {
    const id = idParam(c);
    const q = query(c, reportQuery);
    return asCaller(deps, c, async (tx, me) => {
      if (id !== me.schoolId) throw notFound('School');
      const rows = await tx.query<{
        id: string; full_name: string; section_id: string | null; section_name: string | null;
        present: number; late: number; absent: number; excused: number;
      }>(
        `select p.id, p.full_name, cs.id as section_id, cs.name as section_name,
                count(*) filter (where a.status = 'present')::int as present,
                count(*) filter (where a.status = 'late')::int as late,
                count(*) filter (where a.status = 'absent')::int as absent,
                count(*) filter (where a.status = 'excused')::int as excused
           from attendance_records a
           join people p on p.id = a.student_id
           join class_sections cs on cs.id = a.class_section_id
          where a.period_date between $1 and $2 and ($3::uuid is null or a.class_section_id = $3)
          group by p.id, p.full_name, cs.id, cs.name
          order by cs.name, p.full_name`,
        [q.from, q.to, q.class_section_id ?? null],
      );
      return {
        from: q.from,
        to: q.to,
        rows: rows.rows.map((x) => {
          const total = x.present + x.late + x.absent + x.excused;
          return {
            student: studentRef(x),
            present: x.present, late: x.late, absent: x.absent, excused: x.excused,
            rate_pct: total === 0 ? null : Math.round((1000 * (x.present + x.late)) / total) / 10,
          };
        }),
      };
    });
  };

  r.get('/schools/:id/attendance_report', requireRole('admin'), async (c) => c.json(await loadReport(c)));

  r.get('/schools/:id/attendance_report.csv', requireRole('admin'), async (c) => {
    const report = await loadReport(c);
    const lines = [['Student', 'Section', 'Present', 'Late', 'Absent', 'Excused', 'Rate %']].concat(
      report.rows.map((x) => [
        x.student.full_name, x.student.class_section?.name ?? '', String(x.present), String(x.late), String(x.absent), String(x.excused),
        x.rate_pct == null ? '' : String(x.rate_pct),
      ]),
    );
    return c.body(lines.map((l) => l.map(csvCell).join(',')).join('\r\n') + '\r\n', 200, {
      'content-type': 'text/csv; charset=utf-8',
      'content-disposition': `attachment; filename="attendance_${report.from}_${report.to}.csv"`,
    });
  });

  r.get('/teacher/today', requireRole('teacher'), async (c) => {
    const q = query(c, z.object({ date: isoDate.optional() }));
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const date = q.date ?? todayIn(await schoolTimezone(tx), deps.clock.now());
        const rows = await tx.query<{
          pid: string; subject: string; weekday: number; starts_at: string; ends_at: string; tid: string; tname: string;
          sid: string; sname: string; grade_level: string; term_id: string; enrolled: number; marked: number;
        }>(
          `select p.id as pid, p.subject, p.weekday, p.starts_at, p.ends_at, t.id as tid, t.full_name as tname,
                  cs.id as sid, cs.name as sname, cs.grade_level, cs.term_id,
                  (select count(*)::int from enrollments e where e.class_section_id = cs.id and e.status = 'active') as enrolled,
                  (select count(*)::int from attendance_records a
                    where a.class_section_id = cs.id and a.period_id = p.id and a.period_date = $1::date) as marked
             from periods p
             join class_sections cs on cs.id = p.class_section_id
             join terms tm on tm.id = cs.term_id and $1::date between tm.starts_on and tm.ends_on
             join people t on t.id = p.teacher_id
            where p.teacher_id = app.person_id() and p.weekday = extract(isodow from $1::date)::int
            order by p.starts_at`,
          [date],
        );
        const periods: Schemas['TodayPeriod'][] = rows.rows.map((x) => ({
          period: {
            id: x.pid, subject: x.subject, weekday: x.weekday, starts_at: hhmm(x.starts_at), ends_at: hhmm(x.ends_at),
            teacher: { id: x.tid, full_name: x.tname, role: 'teacher' },
          },
          class_section: { id: x.sid, name: x.sname, grade_level: x.grade_level, term_id: x.term_id },
          register: x.marked === 0 ? 'unmarked' : x.marked < x.enrolled ? 'partial' : 'complete',
          marked: x.marked,
          enrolled: x.enrolled,
        }));
        return { date, periods };
      }),
    );
  });

  r.get('/admin/overview', requireRole('admin'), async (c) =>
    c.json(
      await asCaller(deps, c, async (tx): Promise<Schemas['AdminOverview']> => {
        const today = todayIn(await schoolTimezone(tx), deps.clock.now());
        const rate = await tx.query<{ rate: string | null }>(
          `select round(100.0 * count(*) filter (where status in ('present', 'late')) / nullif(count(*), 0), 1) as rate
             from attendance_records where period_date = $1::date`,
          [today],
        );
        const unmarked = await tx.query<{
          pid: string; subject: string; weekday: number; starts_at: string; ends_at: string; tid: string; tname: string;
          sid: string; sname: string; grade_level: string; term_id: string;
        }>(
          `select p.id as pid, p.subject, p.weekday, p.starts_at, p.ends_at, t.id as tid, t.full_name as tname,
                  cs.id as sid, cs.name as sname, cs.grade_level, cs.term_id
             from periods p
             join class_sections cs on cs.id = p.class_section_id
             join terms tm on tm.id = cs.term_id and $1::date between tm.starts_on and tm.ends_on
             join people t on t.id = p.teacher_id
            where p.weekday = extract(isodow from $1::date)::int
              and not exists (select 1 from attendance_records a where a.period_id = p.id and a.period_date = $1::date)
            order by p.starts_at, cs.name`,
          [today],
        );
        const fees = await tx.query<{ outstanding: string; overdue: number }>(
          `with bal as (
             select i.id, i.due_date, i.amount_due - coalesce(
                      (select sum(p.amount) from payments p where p.invoice_id = i.id and p.status = 'succeeded'), 0) as owed
               from invoices i where i.status <> 'void')
           select coalesce(sum(owed) filter (where owed > 0), 0) as outstanding,
                  count(*) filter (where owed > 0 and due_date < $1::date)::int as overdue from bal`,
          [today],
        );
        const ann = await tx.query<{ id: string; title: string; body: string; class_section_id: string | null; requires_response: boolean; published_at: Date | null }>(
          `select id, title, body, class_section_id, requires_response, published_at from announcements
            where published_at is not null order by published_at desc, id limit 5`,
        );
        return {
          date: today,
          attendance_rate_today_pct: num(rate.rows[0]?.rate),
          registers_unmarked: unmarked.rows.map((x) => ({
            class_section: { id: x.sid, name: x.sname, grade_level: x.grade_level, term_id: x.term_id },
            period: {
              id: x.pid, subject: x.subject, weekday: x.weekday, starts_at: hhmm(x.starts_at), ends_at: hhmm(x.ends_at),
              teacher: { id: x.tid, full_name: x.tname, role: 'teacher' },
            },
            teacher: { id: x.tid, full_name: x.tname, role: 'teacher' },
          })),
          fees_outstanding: Number(fees.rows[0]?.outstanding ?? 0).toFixed(2),
          invoices_overdue: fees.rows[0]?.overdue ?? 0,
          recent_announcements: ann.rows.map((a) => ({
            id: a.id, title: a.title, body: a.body, class_section_id: a.class_section_id,
            requires_response: a.requires_response, published_at: iso(a.published_at),
          })),
        };
      }),
    ),
  );

  return r;
}
