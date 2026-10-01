import { useState } from "react";
import { $api, api } from "../api/client";
import { errorMessage } from "../api/errors";
import { useMe } from "../auth/auth";
import { fmtStamp, pct } from "../lib/format";
import { allItems, cursorPaging } from "../lib/hooks";
import { Btn, Card, DataTable, Field, inputCls, Screen, Tag, go, useApp } from "../ui";
import { LoadMore, useSections } from "./shared";

export function AttendanceReports() {
  const me = useMe();
  const { toast } = useApp();
  const { q: secQ, sections } = useSections();
  const term = me.school.term;
  const [from, setFrom] = useState(term?.starts_on ?? "");
  const [to, setTo] = useState(term?.ends_on ?? "");
  const [sec, setSec] = useState("");
  const ready = !!from && !!to && from <= to;
  const report = $api.useQuery(
    "get",
    "/schools/{id}/attendance_report",
    { params: { path: { id: me.school.id }, query: { from, to, ...(sec ? { class_section_id: sec } : {}) } } },
    { enabled: ready },
  );
  const rows = (report.data?.rows ?? []).map((r) => ({ id: r.student!.id, ...r }));

  const exportCsv = async () => {
    try {
      const { data, error } = await api.GET("/schools/{id}/attendance_report.csv", {
        params: { path: { id: me.school.id }, query: { from, to, ...(sec ? { class_section_id: sec } : {}) } },
        parseAs: "blob",
      });
      if (error || !data) return toast("Could not export the register.");
      const url = URL.createObjectURL(data as Blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `attendance_${from}_${to}.csv`;
      a.click();
      URL.revokeObjectURL(url);
    } catch (e) {
      toast(errorMessage(e));
    }
  };

  return (
    <Screen eyebrow="Reports" title="Attendance reports" queries={[secQ]}>
      {() => (
        <Card plain flush>
          <div className="flex flex-wrap items-end gap-3 border-b border-rule p-3">
            <Field label="From"><input type="date" value={from} onChange={(e) => setFrom(e.target.value)} className={inputCls} /></Field>
            <Field label="To"><input type="date" value={to} onChange={(e) => setTo(e.target.value)} className={inputCls} /></Field>
            <Field label="Section">
              <select value={sec} onChange={(e) => setSec(e.target.value)} className={inputCls}>
                <option value="">All</option>
                {sections.map((s) => (
                  <option key={s.id} value={s.id}>{s.name}</option>
                ))}
              </select>
            </Field>
            <div className="ml-auto"><Btn variant="ghost" disabled={!ready} onClick={() => void exportCsv()}>Export CSV</Btn></div>
          </div>
          {!ready ? (
            <p className="p-6 text-mute">Choose a start date that is not after the end date.</p>
          ) : report.isPending ? (
            <p className="p-6 text-mute">Loading…</p>
          ) : rows.length === 0 ? (
            <p className="p-6 text-mute">No attendance was recorded in this range.</p>
          ) : (
            <DataTable
              cols={[
                { key: "name", label: "Student", render: (r) => <b>{r.student!.full_name}</b> },
                { key: "section", label: "Section", mono: true, render: (r) => r.student!.class_section?.name ?? "" },
                { key: "present", label: "P", mono: true, align: "right" },
                { key: "late", label: "L", mono: true, align: "right" },
                { key: "absent", label: "A", mono: true, align: "right", render: (r) => <span className={(r.absent ?? 0) > 1 ? "font-semibold text-alert" : ""}>{r.absent}</span> },
                { key: "excused", label: "E", mono: true, align: "right" },
                { key: "rate", label: "Rate", mono: true, align: "right", render: (r) => pct(r.rate_pct) },
              ]}
              rows={rows}
            />
          )}
        </Card>
      )}
    </Screen>
  );
}

export function Analytics() {
  return (
    <Screen eyebrow="Trends" title="Analytics" narrow>
      {() => (
        <Card title="Attendance and grade trends" eyebrow="Coming in Term 3">
          <p className="text-sm text-soft">
            Week-by-week attendance and average-grade charts for each section arrive in Term 3. Today, the attendance report and gradebook show the same figures for any date range.
          </p>
          <div className="mt-3 flex gap-2"><Btn variant="ghost" onClick={() => go("/admin/attendance")}>Attendance report</Btn></div>
        </Card>
      )}
    </Screen>
  );
}

const DETAIL: Record<string, string> = {
  student_detail: "Profile",
  student_summary: "Summary",
  student_attendance: "Attendance",
  student_grades: "Grades",
  student_invoices: "Invoices",
  student_homework: "Homework",
};

export function AuditLog() {
  const me = useMe();
  const list = $api.useInfiniteQuery("get", "/audit_log", { params: { query: { limit: 50 } } }, cursorPaging);
  const rows = allItems(list.data);
  return (
    <Screen eyebrow="Security" title="Audit log" queries={[list]} empty={rows.length === 0} emptyText="No reads or changes recorded.">
      {() => (
        <Card plain flush>
          <DataTable
            cols={[
              { key: "at", label: "When", mono: true, className: "whitespace-nowrap", render: (a) => fmtStamp(a.at!, me.school.timezone) },
              { key: "who", label: "Who", render: (a) => <span>{a.actor?.full_name} <span className="text-mute">({a.actor?.role === "guardian" ? "parent" : a.actor?.role})</span></span> },
              { key: "action", label: "Action", render: () => <Tag>Viewed</Tag> },
              { key: "student", label: "Record", render: (a) => a.student?.full_name ?? "" },
              { key: "detail", label: "Detail", render: (a) => DETAIL[a.table_name!] ?? a.table_name },
            ]}
            rows={rows}
          />
          <LoadMore q={list} />
        </Card>
      )}
    </Screen>
  );
}
