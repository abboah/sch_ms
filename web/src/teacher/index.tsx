import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { $api } from "../api/client";
import { Banner, Btn, Card, Screen, inputCls, useApp } from "../ui";
import { ClassOverview } from "./classes";
import { Gradebook, NewAssessment } from "./gradebook";
import { useSectionSubject } from "./shared";
import { Conferences, Homework, Messages } from "./teaching";
import { Attendance, AttendanceIndex, Today } from "./today";

function Comments() {
  const { toast } = useApp();
  const qc = useQueryClient();
  const sel = useSectionSubject();
  const id = sel.section?.id ?? "";
  const q = $api.useQuery("get", "/class_sections/{id}/comments", { params: { path: { id }, query: { subject: sel.subject } } }, { enabled: !!id && !!sel.subject });
  const sheet = q.data;

  const [edits, setEdits] = useState<Record<string, string>>({});
  const [note, setNote] = useState<string | null>(null);
  const value = (studentId: string, server: string | null) => (studentId in edits ? edits[studentId]! : (server ?? ""));
  const dirtyCount = Object.keys(edits).length;

  const save = $api.useMutation("patch", "/class_sections/{id}/comments", {
    onSuccess: (r) => {
      setEdits({});
      setNote(r.rejected ? `${r.applied} saved, ${r.rejected} not accepted.` : "Comments saved.");
      toast(r.rejected ? "Some comments were not accepted" : "Comments saved");
      void qc.invalidateQueries({ queryKey: ["get", "/class_sections/{id}/comments"] });
    },
  });

  return (
    <Screen
      eyebrow={`${sel.section?.name ?? ""} · ${sel.subject} · Term`}
      title="Report card comments"
      queries={[q]}
      locked={sheet?.term_closed}
      empty={sel.mine.length === 0}
      emptyText="You are not assigned to any class this term."
      actions={
        <>
          {sel.mine.length > 1 && (
            <select aria-label="Section" value={sel.section?.id} onChange={(e) => sel.setSec(e.target.value)} className={inputCls + " w-auto"}>
              {sel.mine.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
            </select>
          )}
          {sel.subjects.length > 1 && (
            <select aria-label="Subject" value={sel.subject} onChange={(e) => sel.setSub(e.target.value)} className={inputCls + " w-auto"}>
              {sel.subjects.map((s) => <option key={s}>{s}</option>)}
            </select>
          )}
        </>
      }
    >
      {({ locked }) => (
        <>
          {note && <Banner tone="forest">{note}</Banner>}
          <p className="mb-4 text-sm text-mute">Not visible to parents until the term closes.</p>
          <div className="space-y-3">
            {(sheet?.items ?? []).map((row) => (
              <Card key={row.student.id} plain title={row.student.full_name}>
                <textarea
                  aria-label={`Comment for ${row.student.full_name}`}
                  disabled={locked}
                  rows={2}
                  maxLength={2000}
                  value={value(row.student.id, row.body)}
                  onChange={(e) => setEdits({ ...edits, [row.student.id]: e.target.value })}
                  className={inputCls + " min-h-0 resize-y py-2"}
                  placeholder="Write this pupil's comment…"
                />
              </Card>
            ))}
          </div>
          <div className="mt-4 flex items-center gap-3">
            <Btn
              disabled={locked || save.isPending || dirtyCount === 0}
              onClick={() =>
                save.mutate({
                  params: { path: { id } },
                  body: { subject: sel.subject, comments: Object.entries(edits).map(([student_id, body]) => ({ student_id, body })) },
                })
              }
            >
              {save.isPending ? "Saving…" : "Save comments"}
            </Btn>
            {dirtyCount > 0 && <span className="text-sm text-mute">{dirtyCount} not saved yet.</span>}
          </div>
        </>
      )}
    </Screen>
  );
}

/** The teacher portal. Paths: /teacher/attendance/:sectionId/:periodId/:date?, /teacher/gradebook/new/:sectionId/:subject */
export default function TeacherPages({ path }: { path: string }) {
  const p = path.split("/").filter(Boolean);
  switch (p[1]) {
    case "attendance": return p[2] && p[3] ? <Attendance sec={p[2]} period={p[3]} date={p[4]} /> : <AttendanceIndex />;
    case "class": return <ClassOverview sec={p[2]} />;
    case "gradebook": return p[2] === "new" ? <NewAssessment sec={p[3]} subject={p[4] ? decodeURIComponent(p[4]) : undefined} /> : <Gradebook />;
    case "comments": return <Comments />;
    case "homework": return <Homework />;
    case "messages": return <Messages />;
    case "conferences": return <Conferences />;
    default: return <Today />;
  }
}
