import { useState } from "react";
import { $api } from "../api/client";
import { appNow } from "../api/session";
import { useMe } from "../auth/auth";
import { fmtDay, fmtDayWeekday, fmtMonthYear, pct, toLetter, todayIn, type Status } from "../lib/format";
import { Btn, Card, Screen, StatusChip } from "../ui";
import { ChildSwitcher, NoChildren, useChild } from "./shared";

/** Across several periods in a day, show the most notable status: absent, then late, then excused, then present. */
const RANK: Record<Status, number> = { A: 3, L: 2, E: 1, P: 0 };
const worst = (list: Status[]): Status => list.reduce((a, b) => (RANK[b] > RANK[a] ? b : a));

function monthBounds(month: string) {
  const [y, m] = month.split("-").map(Number) as [number, number];
  const last = new Date(Date.UTC(y, m, 0)).getUTCDate();
  return { from: `${month}-01`, to: `${month}-${String(last).padStart(2, "0")}`, last, firstWeekday: new Date(Date.UTC(y, m - 1, 1)).getUTCDay() };
}
const shiftMonth = (month: string, by: number) => {
  const [y, m] = month.split("-").map(Number) as [number, number];
  const d = new Date(Date.UTC(y, m - 1 + by, 1));
  return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, "0")}`;
};

export function Attendance() {
  const me = useMe();
  const c = useChild();
  const [month, setMonth] = useState(() => todayIn(me.school.timezone).slice(0, 7));
  const { from, to, last, firstWeekday } = monthBounds(month);
  const q = $api.useQuery("get", "/students/{id}/attendance", { params: { path: { id: c?.id ?? "" }, query: { from, to } } }, { enabled: !!c });

  const byDay = new Map<string, Status[]>();
  const notes = new Map<string, string>();
  for (const r of q.data?.items ?? []) {
    byDay.set(r.period_date, [...(byDay.get(r.period_date) ?? []), toLetter(r.status)]);
    if (r.note) notes.set(r.period_date, r.note);
  }

  // Monday-first grid of weekdays only, like the design; weekends are not school days.
  const cells: { d: number; s: Status | null }[][] = [];
  let week: { d: number; s: Status | null }[] = [];
  const lead = (firstWeekday + 6) % 7; // blanks before day 1 when it is not a Monday
  for (let i = 0; i < Math.min(lead, 5); i++) week.push({ d: 0, s: null });
  for (let d = 1; d <= last; d++) {
    const dow = new Date(Date.UTC(Number(month.slice(0, 4)), Number(month.slice(5, 7)) - 1, d)).getUTCDay();
    if (dow === 0 || dow === 6) continue;
    const key = `${month}-${String(d).padStart(2, "0")}`;
    const list = byDay.get(key);
    week.push({ d, s: list ? worst(list) : null });
    if (week.length === 5) { cells.push(week); week = []; }
  }
  if (week.length) { while (week.length < 5) week.push({ d: 0, s: null }); cells.push(week); }

  const recent = [...byDay.entries()].sort((a, b) => b[0].localeCompare(a[0])).slice(0, 5);

  return (
    <Screen eyebrow={fmtMonthYear(from)} title="Attendance" narrow queries={c ? [q] : []}>
      {() =>
        !c ? <NoChildren /> : (
          <>
            <ChildSwitcher />
            <Card title="Month" actions={<div className="flex gap-1"><Btn variant="ghost" aria-label="Previous month" onClick={() => setMonth(shiftMonth(month, -1))}>Earlier</Btn><Btn variant="ghost" aria-label="Next month" onClick={() => setMonth(shiftMonth(month, 1))}>Later</Btn></div>}>
              <div className="grid grid-cols-5 gap-1.5 text-center">
                {["Mon", "Tue", "Wed", "Thu", "Fri"].map((d) => <div key={d} className="eyebrow pb-1">{d}</div>)}
                {cells.flat().map((x, i) => (
                  <div key={i} className={`flex min-h-14 flex-col items-center justify-center rounded-reg border ${x.d ? "border-rule bg-paper" : "border-transparent"}`}>
                    {x.d > 0 && <span className="mono text-xs text-mute">{x.d}</span>}
                    {x.s && <StatusChip s={x.s} compact />}
                  </div>
                ))}
              </div>
              <p className="mt-3 text-xs text-mute">P present, L late, A absent, E excused. When a day has several registers, the most notable mark is shown.</p>
            </Card>
            <Card title="Recent school days" className="mt-5" flush>
              {recent.length === 0 ? <p className="p-4 text-mute">No attendance has been recorded this month.</p> : (
                <ul className="divide-y divide-rule">
                  {recent.map(([date, list]) => (
                    <li key={date} className="flex items-center gap-3 px-4 py-2.5">
                      <span className="mono w-24 text-sm text-mute">{fmtDayWeekday(date)}</span>
                      <StatusChip s={worst(list)} />
                      {notes.get(date) && <span className="text-sm text-soft">{notes.get(date)}</span>}
                    </li>
                  ))}
                </ul>
              )}
            </Card>
          </>
        )
      }
    </Screen>
  );
}

export function Grades() {
  const c = useChild();
  const q = $api.useQuery("get", "/students/{id}/grades", { params: { path: { id: c?.id ?? "" } } }, { enabled: !!c });
  const subjects = q.data?.subjects ?? [];
  return (
    <Screen eyebrow="This term" title="Grades" narrow queries={c ? [q] : []} empty={!!c && subjects.length === 0} emptyText="No grades have been posted.">
      {() =>
        !c ? <NoChildren /> : (
          <>
            <ChildSwitcher />
            <div className="space-y-5">
              {subjects.map((s) => (
                <Card
                  key={`${s.class_section_id}-${s.subject}`}
                  title={s.subject}
                  eyebrow="Running grade"
                  actions={
                    <span className="mono text-2xl font-medium">
                      {pct(s.running_grade)}
                      {s.grade_band && <span className="ml-1.5 text-sm text-mute">({s.grade_band})</span>}
                    </span>
                  }
                >
                  <ul className="divide-y divide-rule text-sm">
                    {s.assessments.map((a) => (
                      <li key={a.id} className="flex justify-between gap-3 py-2">
                        <span>{a.title} <span className="mono text-xs text-mute">{a.weight}%</span>{a.comment && <span className="block text-xs text-soft">{a.comment}</span>}</span>
                        <span className={`mono ${a.score == null ? "text-mute" : ""}`}>{a.score == null ? "Not yet scored" : `${a.score}/${a.max_score}`}</span>
                      </li>
                    ))}
                  </ul>
                </Card>
              ))}
            </div>
          </>
        )
      }
    </Screen>
  );
}

export function Reports() {
  const c = useChild();
  const q = $api.useQuery("get", "/students/{id}/report_comments", { params: { path: { id: c?.id ?? "" } } }, { enabled: !!c });
  const items = q.data?.items ?? [];
  return (
    <Screen eyebrow={c?.full_name} title="Report cards" narrow queries={c ? [q] : []} empty={!!c && items.length === 0} emptyText="No comments have been issued yet. They appear here once each term closes.">
      {() =>
        !c ? <NoChildren /> : (
          <>
            <ChildSwitcher />
            <div className="space-y-4">
              {items.map((x) => (
                <Card key={`${x.class_section_id}-${x.subject}`} title={x.subject} eyebrow={x.teacher.full_name}>
                  <p className="text-sm text-soft">{x.body}</p>
                </Card>
              ))}
            </div>
            <p className="mt-4 text-xs text-mute">Downloadable report cards arrive later; for now the Grades page shows every score and running grade as it is posted.</p>
          </>
        )
      }
    </Screen>
  );
}

export function Homework() {
  const me = useMe();
  const c = useChild();
  const since = new Date(appNow().getTime() - 14 * 24 * 3600 * 1000);
  const q = $api.useQuery("get", "/students/{id}/homework", { params: { path: { id: c?.id ?? "" }, query: { due_from: todayIn(me.school.timezone, since) } } }, { enabled: !!c });
  const items = q.data?.items ?? [];
  return (
    <Screen eyebrow="Recent and upcoming" title="Homework" narrow queries={c ? [q] : []} emptyText={`No homework is due for ${c?.full_name ?? "your child"}.`}>
      {() =>
        !c ? <NoChildren /> : (
          <>
            <ChildSwitcher />
            {items.length === 0 ? (
              <p className="rounded-reg border border-dashed border-rule p-8 text-center text-mute">No homework has been posted for {c.full_name} recently.</p>
            ) : (
              <Card flush>
                <ul className="divide-y divide-rule">
                  {items.map((h) => (
                    <li key={h.id} className="px-4 py-3">
                      <div className="font-semibold">{h.subject ?? "Homeroom"}: {h.title}</div>
                      <div className="eyebrow">Due {fmtDay(h.due_date)}</div>
                      {h.body && <p className="mt-1 text-sm text-soft">{h.body}</p>}
                    </li>
                  ))}
                </ul>
              </Card>
            )}
          </>
        )
      }
    </Screen>
  );
}
