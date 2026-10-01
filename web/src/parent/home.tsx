import { $api } from "../api/client";
import { useMe } from "../auth/auth";
import { fmtDay, fmtLong, fmtStamp, fmtTime, money, toLetter, todayIn } from "../lib/format";
import { Banner, Card, Link, Screen, StatTile, StatusChip } from "../ui";
import { ChildSwitcher, NoChildren, useChild } from "./shared";

export function Home() {
  const me = useMe();
  const tz = me.school.timezone;
  const c = useChild();
  const today = todayIn(tz);
  const id = c?.id ?? "";
  const on = { enabled: !!id };

  const invoices = $api.useQuery("get", "/students/{id}/invoices", { params: { path: { id } } }, on);
  const grades = $api.useQuery("get", "/students/{id}/grades", { params: { path: { id } } }, on);
  const attendance = $api.useQuery("get", "/students/{id}/attendance", { params: { path: { id }, query: { from: today, to: today } } }, on);
  const homework = $api.useQuery("get", "/students/{id}/homework", { params: { path: { id }, query: { due_from: today } } }, on);
  const notice = $api.useQuery("get", "/announcements", { params: { query: { limit: 1 } } });

  const owed = (invoices.data?.items ?? []).reduce((sum, i) => sum + Number(i.outstanding), 0);
  const overdue = (invoices.data?.items ?? []).find((i) => i.overdue);
  const latest = (grades.data?.subjects ?? [])
    .flatMap((s) => s.assessments.filter((a) => a.score != null).map((a) => ({ ...a, subject: s.subject })))
    .sort((a, b) => (b.due_date ?? "").localeCompare(a.due_date ?? ""))[0];
  const todayRecord = attendance.data?.items[0];
  const firstName = me.full_name.split(" ")[0];

  return (
    <Screen eyebrow={fmtLong(today)} title={`Hello, ${firstName}`} narrow queries={c ? [invoices, grades] : []}>
      {() =>
        !c ? <NoChildren /> : (
          <>
            <ChildSwitcher />
            {overdue && (
              <Banner tone="alert">
                {c.full_name.split(" ")[0]}'s balance of {money(overdue.outstanding)} was due on {fmtDay(overdue.due_date)}. <Link to="/parent/fees" className="font-semibold underline">Pay now</Link>
              </Banner>
            )}
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="rounded-reg border border-rule border-t-[3px] border-t-accent bg-raised p-4">
                <div className="eyebrow">Attendance today</div>
                <div className="mt-2">{todayRecord ? <StatusChip s={toLetter(todayRecord.status)} /> : <span className="text-mute">Not marked yet</span>}</div>
                <div className="mt-1 text-sm text-mute">{todayRecord ? `Marked ${fmtTime(todayRecord.marked_at, tz)}` : "Registers open in the morning"}</div>
              </div>
              <StatTile
                label="Latest grade"
                value={latest ? `${Math.round((100 * (latest.score ?? 0)) / latest.max_score)}%` : "n/a"}
                sub={latest ? `${latest.subject}, ${latest.title}` : "No scores yet"}
              />
              <StatTile label="Balance owed" value={owed > 0 ? money(owed) : money(0)} sub={owed > 0 ? (overdue ? `Overdue since ${fmtDay(overdue.due_date)}` : "Open invoices") : "Paid in full"} tone={overdue ? "alert" : undefined} />
              <Card title="Homework due">
                {(homework.data?.items ?? []).length === 0 ? (
                  <p className="text-sm text-mute">Nothing due.</p>
                ) : (
                  <ul className="text-sm">
                    {homework.data!.items.slice(0, 2).map((h) => (
                      <li key={h.id} className="border-b border-rule/70 py-1.5 last:border-0">
                        <b>{h.subject ?? "Homeroom"}</b>: {h.title} <span className="mono text-xs text-mute">{fmtDay(h.due_date)}</span>
                      </li>
                    ))}
                  </ul>
                )}
              </Card>
            </div>
            {notice.data?.items[0] && (
              <div className="mt-5">
                <Card title={notice.data.items[0].title} eyebrow={notice.data.items[0].published_at ? fmtStamp(notice.data.items[0].published_at, tz) : undefined}>
                  <p className="text-sm">{notice.data.items[0].body}</p>
                  <Link to="/parent/announcements" className="mt-2 inline-block text-sm font-semibold text-accent">All notices</Link>
                </Card>
              </div>
            )}
          </>
        )
      }
    </Screen>
  );
}
