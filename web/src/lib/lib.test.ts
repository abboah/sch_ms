import { describe, expect, test } from "vitest";
import { fmtDay, fmtDayWeekday, fromLetter, money, pct, toLetter, todayIn } from "./format";
import { gradeBandFor, parseScore, runningGrade } from "./grades";
import { zonedToIso } from "./tz";

describe("zonedToIso: a wall-clock time in the school's timezone becomes the right instant", () => {
  test("Accra is UTC all year", () => {
    expect(zonedToIso("2026-10-24", "09:00", "Africa/Accra")).toBe("2026-10-24T09:00:00.000Z");
  });
  test("a zone ahead of UTC moves the instant earlier", () => {
    expect(zonedToIso("2026-10-24", "09:00", "Africa/Lagos")).toBe("2026-10-24T08:00:00.000Z");
    expect(zonedToIso("2026-10-24", "09:00", "Asia/Kolkata")).toBe("2026-10-24T03:30:00.000Z");
  });
  test("daylight saving is honoured on each side of the change", () => {
    // New York: clocks go forward on 8 March 2026 (UTC-5 becomes UTC-4)
    expect(zonedToIso("2026-03-07", "09:00", "America/New_York")).toBe("2026-03-07T14:00:00.000Z");
    expect(zonedToIso("2026-03-09", "09:00", "America/New_York")).toBe("2026-03-09T13:00:00.000Z");
  });
  test("the browser's own timezone is irrelevant", () => {
    const before = process.env.TZ;
    expect(zonedToIso("2026-10-24", "09:00", "Africa/Accra")).toBe("2026-10-24T09:00:00.000Z");
    expect(process.env.TZ).toBe(before);
  });
});

describe("running grade", () => {
  const items = [
    { score: 8, max_score: 10, weight: 10 },
    { score: 72, max_score: 100, weight: 25 },
    { score: 15, max_score: 20, weight: 20 },
    { score: null, max_score: 100, weight: 45 },
  ];
  test("weights only what has been scored: Kofi's 74.5", () => expect(runningGrade(items)).toBe(74.5));
  test("Yaa's 89.1", () =>
    expect(runningGrade([{ score: 9, max_score: 10, weight: 10 }, { score: 88, max_score: 100, weight: 25 }, { score: 18, max_score: 20, weight: 20 }])).toBe(89.1));
  test("nothing scored is n/a, not zero", () => {
    expect(runningGrade([])).toBeNull();
    expect(runningGrade([{ score: null, max_score: 10, weight: 50 }])).toBeNull();
    expect(pct(null)).toBe("n/a");
  });
  test("a typed score is cleared when blank, clamped to the maximum, and rejected when not a number", () => {
    expect(parseScore("", 20)).toBeNull();
    expect(parseScore("  ", 20)).toBeNull();
    expect(parseScore("15", 20)).toBe(15);
    expect(parseScore("25", 20)).toBe(20);
    expect(parseScore("-3", 20)).toBe(0);
    expect(parseScore("abc", 20)).toBe("invalid");
  });
});

describe("grade bands", () => {
  const bands = [{ label: "A", min_score: 80, max_score: 100 }, { label: "B", min_score: 70, max_score: 79.9 }, { label: "C", min_score: 0, max_score: 69.9 }];
  test("picks the band containing the score", () => {
    expect(gradeBandFor(74.5, bands)).toBe("B");
    expect(gradeBandFor(100, bands)).toBe("A");
    expect(gradeBandFor(0, bands)).toBe("C");
  });
  test("no score or no configured scale is null, not a guess", () => {
    expect(gradeBandFor(null, bands)).toBeNull();
    expect(gradeBandFor(74.5, [])).toBeNull();
  });
});

describe("formatting", () => {
  test("money keeps two decimals and thousands separators", () => {
    expect(money("1850.00")).toBe("GH¢ 1,850.00");
    expect(money(600)).toBe("GH¢ 600.00");
    expect(money(null)).toBe("GH¢ 0.00");
  });
  test("calendar dates never shift a day, whatever the browser's timezone", () => {
    expect(fmtDay("2026-10-05")).toBe("5 Oct");
    expect(fmtDayWeekday("2026-10-05")).toBe("Mon 5 Oct");
  });
  test("'today' is decided in the school's timezone", () => {
    const t = new Date("2026-10-05T23:30:00Z");
    expect(todayIn("Africa/Accra", t)).toBe("2026-10-05");
    expect(todayIn("Pacific/Auckland", t)).toBe("2026-10-06");
  });
  test("attendance letters round-trip with the API's words", () => {
    for (const s of ["present", "late", "absent", "excused"] as const) expect(fromLetter(toLetter(s))).toBe(s);
  });
});
