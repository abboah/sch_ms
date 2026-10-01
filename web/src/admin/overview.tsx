import { $api } from "../api/client";
import { useMe } from "../auth/auth";
import { fmtLong, fmtStamp, money, pct } from "../lib/format";
import { Card, DataTable, Link, Screen, StatTile, Tag } from "../ui";

export function Overview() {
  const me = useMe();
  const q = $api.useQuery("get", "/admin/overview");
  const o = q.data;
  const chase = (o?.registers_unmarked ?? []).map((r, i) => ({
    id: String(i),
    s: r.class_section?.name ?? "",
    subject: r.period?.subject ?? "",
    p: `${r.period?.subject ?? ""} at ${r.period?.starts_at ?? ""}`,
    t: r.teacher?.full_name ?? "",
  }));
  return (
    <Screen eyebrow={o ? fmtLong(o.date) : "Today"} title="Overview" queries={[q]}>
      {() => (
        <div className="space-y-5">
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <StatTile
              label="Attendance today"
              value={pct(o?.attendance_rate_today_pct)}
              sub={o?.attendance_rate_today_pct == null ? "No registers marked yet" : "Across registers marked so far"}
            />
            <StatTile
              label="Unmarked registers"
              value={String(chase.length)}
              sub={chase.slice(0, 2).map((c) => `${c.s} ${c.subject}`).join(", ") || "All marked"}
              tone={chase.length ? "alert" : undefined}
            />
            <StatTile label="Fees outstanding" value={money(o?.fees_outstanding)} sub="Across all open invoices" />
            <StatTile label="Overdue invoices" value={String(o?.invoices_overdue ?? 0)} sub="Past their due date" tone={o?.invoices_overdue ? "alert" : undefined} />
          </div>
          <div className="grid gap-5 lg:grid-cols-[3fr_2fr]">
            <Card title="Registers to chase" eyebrow="Today">
              {chase.length === 0 ? (
                <p className="text-mute">Every register for today has been started.</p>
              ) : (
                <DataTable
                  cols={[
                    { key: "s", label: "Section", mono: true },
                    { key: "p", label: "Period" },
                    { key: "t", label: "Teacher" },
                    { key: "x", label: "", render: () => <Tag tone="alert">Unmarked</Tag> },
                  ]}
                  rows={chase}
                />
              )}
            </Card>
            <Card title="Recent announcements" actions={<Link to="/admin/announcements" className="text-sm font-semibold text-accent">All</Link>}>
              <ul className="divide-y divide-rule">
                {(o?.recent_announcements ?? []).map((a) => (
                  <li key={a.id} className="py-2.5 first:pt-0 last:pb-0">
                    <div className="font-semibold">{a.title}</div>
                    <div className="eyebrow">{a.published_at ? fmtStamp(a.published_at, me.school.timezone) : "Draft"}</div>
                  </li>
                ))}
              </ul>
            </Card>
          </div>
        </div>
      )}
    </Screen>
  );
}
