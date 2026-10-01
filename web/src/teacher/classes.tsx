import { useState } from "react";
import { $api } from "../api/client";
import { pct } from "../lib/format";
import { Card, DataTable, inputCls, Screen, StatTile, go } from "../ui";
import { teachingSubjects, useMySections } from "./shared";

export function ClassOverview({ sec }: { sec?: string }) {
  const mine = useMySections();
  const [chosen, setChosen] = useState(sec ?? "");
  const id = chosen || mine[0]?.id || "";
  const section = mine.find((s) => s.id === id);
  const subject = teachingSubjects(section?.subject)[0];
  const detail = $api.useQuery("get", "/class_sections/{id}", { params: { path: { id } } }, { enabled: !!id });
  const book = $api.useQuery("get", "/class_sections/{id}/gradebook", { params: { path: { id }, query: subject ? { subject } : {} } }, { enabled: !!id });

  const grades = new Map((book.data?.rows ?? []).map((r) => [r.student.id, r.running_grade]));
  const scored = [...grades.values()].filter((g): g is number => g != null);
  const average = scored.length ? Math.round((10 * scored.reduce((a, b) => a + b, 0)) / scored.length) / 10 : null;
  const roster = detail.data?.roster ?? [];

  return (
    <Screen
      eyebrow="Class"
      title={`Section ${section?.name ?? ""}`}
      queries={[detail, book]}
      empty={mine.length === 0}
      emptyText="You are not assigned to any class this term."
      actions={
        mine.length > 1 && (
          <select aria-label="Section" value={id} onChange={(e) => setChosen(e.target.value)} className={inputCls + " w-auto"}>
            {mine.map((s) => (
              <option key={s.id} value={s.id}>{s.name}</option>
            ))}
          </select>
        )
      }
    >
      {() => (
        <div className="space-y-5">
          <div className="grid gap-4 sm:grid-cols-3">
            <StatTile label="Students" value={String(roster.length)} />
            <StatTile label="Attendance" value={pct(detail.data?.attendance_rate_pct)} />
            <StatTile label={subject ? `${subject} average` : "Average"} value={pct(average)} />
          </div>
          <Card plain flush>
            <DataTable
              onRow={() => go("/teacher/gradebook")}
              cols={[
                { key: "full_name", label: "Student", render: (r) => <b>{r.full_name}</b> },
                { key: "att", label: "Attendance", mono: true, align: "right", render: (r) => <span className={r.attendance_rate_pct != null && r.attendance_rate_pct < 90 ? "font-semibold text-alert" : ""}>{pct(r.attendance_rate_pct)}</span> },
                { key: "avg", label: "Running avg", mono: true, align: "right", render: (r) => pct(grades.get(r.id)) },
              ]}
              rows={roster}
            />
          </Card>
        </div>
      )}
    </Screen>
  );
}

