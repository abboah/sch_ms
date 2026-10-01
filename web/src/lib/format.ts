import { appNow } from "../api/session";

/** Formatting shared across screens. Money arrives as decimal strings ("1850.00") and is never a float on the wire. */

export const money = (v: string | number | null | undefined): string =>
  "GH¢ " + Number(v ?? 0).toLocaleString("en-GH", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const dayMonth = new Intl.DateTimeFormat("en-GB", { day: "numeric", month: "short", timeZone: "UTC" });
const weekdayDayMonth = new Intl.DateTimeFormat("en-GB", { weekday: "short", day: "numeric", month: "short", timeZone: "UTC" });
const longDate = new Intl.DateTimeFormat("en-GB", { weekday: "long", day: "numeric", month: "long", timeZone: "UTC" });
const monthYear = new Intl.DateTimeFormat("en-GB", { month: "long", year: "numeric", timeZone: "UTC" });

/** Dates from the API are calendar dates (YYYY-MM-DD); format them in UTC so they never shift a day. */
const asUtc = (d: string) => new Date(d.length === 10 ? `${d}T00:00:00Z` : d);
export const fmtDay = (d: string) => dayMonth.format(asUtc(d));
export const fmtDayWeekday = (d: string) => weekdayDayMonth.format(asUtc(d)).replace(",", "");
export const fmtLong = (d: string) => longDate.format(asUtc(d));
export const fmtMonthYear = (d: string) => monthYear.format(asUtc(d));

/** A timestamp as a short time in the school's timezone, e.g. "07:52". */
export const fmtTime = (iso: string, timeZone: string) =>
  new Intl.DateTimeFormat("en-GB", { hour: "2-digit", minute: "2-digit", timeZone }).format(new Date(iso));

/** "Mon 5 Oct, 07:52" */
export const fmtStamp = (iso: string, timeZone: string) =>
  new Intl.DateTimeFormat("en-GB", { weekday: "short", day: "numeric", month: "short", hour: "2-digit", minute: "2-digit", timeZone })
    .format(new Date(iso))
    .replace(",", "");

/** Today as YYYY-MM-DD in a timezone. */
export const todayIn = (timeZone: string, now: Date = appNow()) =>
  new Intl.DateTimeFormat("en-CA", { timeZone, year: "numeric", month: "2-digit", day: "2-digit" }).format(now);

export const pct = (n: number | null | undefined) => (n == null ? "n/a" : `${n.toFixed(1)}%`);

/** API statuses <-> the one-letter codes the design uses. */
export type Status = "P" | "L" | "A" | "E";
export const toLetter = (s: "present" | "late" | "absent" | "excused"): Status => ({ present: "P", late: "L", absent: "A", excused: "E" } as const)[s];
export const fromLetter = (s: Status) => ({ P: "present", L: "late", A: "absent", E: "excused" } as const)[s];
