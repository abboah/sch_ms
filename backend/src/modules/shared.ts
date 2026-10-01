import type { Tx } from '../context.ts';
import { notFound } from '../http/errors.ts';
import type { Schemas } from '../http/helpers.ts';

/** Small mappers and queries several modules share. Kept tiny on purpose. */

export const personRef = (r: { id: string; full_name: string; role: Schemas['Role'] }): Schemas['Person'] => ({
  id: r.id,
  full_name: r.full_name,
  role: r.role,
});

export interface StudentRow {
  id: string;
  full_name: string;
  section_id?: string | null;
  section_name?: string | null;
}

export const studentRef = (r: StudentRow): Schemas['StudentRef'] => ({
  id: r.id,
  full_name: r.full_name,
  ...(r.section_id && r.section_name ? { class_section: { id: r.section_id, name: r.section_name } } : {}),
});

/** "Today" as a YYYY-MM-DD string in the school's timezone. */
export function todayIn(timeZone: string, now: Date): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone, year: 'numeric', month: '2-digit', day: '2-digit' }).format(now);
}

export async function schoolTimezone(tx: Tx): Promise<string> {
  const r = await tx.query<{ timezone: string }>('select timezone from schools where id = app.school_id()');
  return r.rows[0]?.timezone ?? 'UTC';
}

/**
 * A student the caller may see, or 404. The read is written to the audit log, because who looks
 * at a child's record is part of safeguarding.
 */
export async function visibleStudent(tx: Tx, studentId: string, auditAs: string): Promise<{ id: string; full_name: string }> {
  const r = await tx.query<{ id: string; full_name: string }>(
    `select id, full_name from people where id = $1 and role = 'student'`,
    [studentId],
  );
  const row = r.rows[0];
  if (!row) throw notFound('Student');
  await tx.query('select app.log_read($1, $2)', [studentId, auditAs]);
  return row;
}

export const round1 = (n: number): number => Math.round(n * 10) / 10;

/** Weighted over assessments that have a score; null when nothing is scored yet. */
export function runningGrade(items: { score: number | null; max_score: number; weight: number }[]): number | null {
  let got = 0;
  let weights = 0;
  for (const i of items) {
    if (i.score == null) continue;
    got += (i.score / i.max_score) * i.weight;
    weights += i.weight;
  }
  return weights === 0 ? null : round1((100 * got) / weights);
}

export interface GradeBandRange { label: string; min_score: number; max_score: number }

/** Mirrors app.grade_band() in SQL: the band whose range contains the score, or null if none configured or nothing scored. */
export function gradeBandFor(score: number | null, bands: GradeBandRange[]): string | null {
  if (score == null) return null;
  let best: GradeBandRange | null = null;
  for (const b of bands) {
    if (score >= b.min_score && score <= b.max_score && (!best || b.min_score > best.min_score)) best = b;
  }
  return best?.label ?? null;
}

export const num = (v: string | number | null | undefined): number | null => (v == null ? null : Number(v));

/** 'HH:MM:SS' -> 'HH:MM' */
export const hhmm = (t: string): string => t.slice(0, 5);
