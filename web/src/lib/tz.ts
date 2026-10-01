/**
 * Turn a wall-clock date and time in a named timezone into the UTC instant it means.
 * ("2026-10-24", "09:00", "Africa/Accra") -> "2026-10-24T09:00:00.000Z". The browser's own timezone is
 * deliberately ignored: a registrar in another country still schedules in the school's time.
 */
export function zonedToIso(date: string, time: string, timeZone: string): string {
  const [y, mo, d] = date.split("-").map(Number) as [number, number, number];
  const [h, mi] = time.split(":").map(Number) as [number, number];
  // Guess the instant as if it were UTC, see what wall clock the zone shows for it, and correct by the difference.
  const guess = Date.UTC(y, mo - 1, d, h, mi);
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone, hourCycle: "h23", year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit",
  }).formatToParts(new Date(guess));
  const get = (t: string) => Number(parts.find((p) => p.type === t)!.value);
  const shown = Date.UTC(get("year"), get("month") - 1, get("day"), get("hour"), get("minute"));
  return new Date(guess - (shown - guess)).toISOString();
}
