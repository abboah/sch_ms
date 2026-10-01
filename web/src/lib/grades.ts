/**
 * The running grade, computed the same way the server does (so a teacher typing scores sees the same
 * number the parent will see once saved): weighted over the assessments that have a score.
 * Returns null when nothing is scored yet.
 */
export function runningGrade(items: { score: number | null | undefined; max_score: number; weight: number }[]): number | null {
  let got = 0;
  let weights = 0;
  for (const i of items) {
    if (i.score == null) continue;
    got += (i.score / i.max_score) * i.weight;
    weights += i.weight;
  }
  return weights === 0 ? null : Math.round((1000 * got) / weights) / 10;
}

export interface GradeBandRange { label: string; min_score: number; max_score: number }

/** Mirrors the server's app.grade_band(): the band whose range contains the score, or null. */
export function gradeBandFor(score: number | null, bands: GradeBandRange[]): string | null {
  if (score == null) return null;
  let best: GradeBandRange | null = null;
  for (const b of bands) {
    if (score >= b.min_score && score <= b.max_score && (!best || b.min_score > best.min_score)) best = b;
  }
  return best?.label ?? null;
}

/** Parse what a teacher typed into a score cell: blank clears it, otherwise clamp to 0..max. */
export function parseScore(raw: string, max: number): number | null | "invalid" {
  const t = raw.trim();
  if (t === "") return null;
  const n = Number(t);
  if (!Number.isFinite(n)) return "invalid";
  return Math.max(0, Math.min(max, n));
}
