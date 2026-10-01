import { useState } from "react";
import { $api } from "../api/client";
import type { Me } from "../api/session";
import { appNow } from "../api/session";
import { useMe } from "../auth/auth";

/** What a teacher teaches in a section, without the implicit "Homeroom" duty: ["Maths"]. */
export const teachingSubjects = (subject: string | undefined): string[] =>
  (subject ?? "").split(", ").filter((s) => s && s !== "Homeroom");

export type MySection = NonNullable<Me["sections"]>[number];

/** The sections this teacher teaches in the current term (already on the signed-in person). */
export function useMySections(): MySection[] {
  return useMe().sections ?? [];
}

/** Which section and subject a screen is showing, picked from what this teacher teaches. */
export function useSectionSubject() {
  const mine = useMySections();
  const [sec, setSec] = useState("");
  const [sub, setSub] = useState("");
  const section = mine.find((s) => s.id === sec) ?? mine[0];
  const subjects = teachingSubjects(section?.subject);
  const subject = subjects.includes(sub) ? sub : (subjects[0] ?? "");
  return { mine, section, subjects, subject, setSec, setSub };
}

/** Today's periods (or another date's), the source for the register list and screen titles. */
export function useToday(date?: string) {
  return $api.useQuery("get", "/teacher/today", { params: { query: date ? { date } : {} } });
}

export function greeting(timeZone: string, now: Date = appNow()): string {
  const hour = Number(new Intl.DateTimeFormat("en-GB", { hour: "numeric", hourCycle: "h23", timeZone }).format(now));
  return hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";
}
