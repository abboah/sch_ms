import { useRef, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { $api } from "../api/client";
import { errorMessage } from "../api/errors";
import { fmtDay, pct } from "../lib/format";
import { gradeBandFor, parseScore, runningGrade } from "../lib/grades";
import { outbox } from "../offline/queue";
import { Banner, Btn, Card, Field, inputCls, Screen, go, useApp } from "../ui";
import { teachingSubjects, useMySections, useSectionSubject } from "./shared";

export function Gradebook() {
  const { toast } = useApp();
  const qc = useQueryClient();
  const sel = useSectionSubject();
  const id = sel.section?.id ?? "";
  const q = $api.useQuery("get", "/class_sections/{id}/gradebook", { params: { path: { id }, query: sel.subject ? { subject: sel.subject } : {} } }, { enabled: !!id });
  const book = q.data;
  const bands = $api.useQuery("get", "/grade_bands").data?.items ?? [];

  // Edits typed but not yet saved, keyed "assessmentId|studentId" -> the raw text in the cell.
  const [edits, setEdits] = useState<Record<string, string>>({});
  const [note, setNote] = useState<{ tone: "forest" | "brass" | "alert"; text: string } | null>(null);
  const [saving, setSaving] = useState(false);
  const grid = useRef<HTMLDivElement>(null);

  const cellValue = (aid: string, sid: string, server: number | null | undefined) => {
    const k = `${aid}|${sid}`;
    return k in edits ? edits[k]! : server == null ? "" : String(server);
  };

  const average = (row: NonNullable<typeof book>["rows"][number]) =>
    runningGrade(
      (book?.assessments ?? []).map((a) => {
        const raw = cellValue(a.id, row.student.id, row.scores[a.id]);
        const parsed = parseScore(raw, a.max_score);
        return { score: parsed === "invalid" ? null : parsed, max_score: a.max_score, weight: a.weight };
      }),
    );

  const move = (e: React.KeyboardEvent, r: number, c: number) => {
    const input = e.target as HTMLInputElement;
    const d =
      e.key === "ArrowDown" || e.key === "Enter" ? [1, 0]
      : e.key === "ArrowUp" ? [-1, 0]
      : e.key === "ArrowLeft" && input.selectionStart === 0 ? [0, -1]
      : e.key === "ArrowRight" ? [0, 1]
      : null;
    if (!d) return;
    e.preventDefault();
    grid.current?.querySelector<HTMLInputElement>(`[data-cell="${r + d[0]!}-${c + d[1]!}"]`)?.focus();
  };

  const dirtyCount = Object.keys(edits).length;

  const save = async () => {
    if (!book) return;
    setSaving(true);
    setNote(null);
    // One batch per assessment, each queued if the network is down.
    const byAssessment = new Map<string, { student_id: string; score: number | null }[]>();
    for (const [key, raw] of Object.entries(edits)) {
      const [aid, sid] = key.split("|") as [string, string];
      const a = book.assessments.find((x) => x.id === aid);
      const parsed = a ? parseScore(raw, a.max_score) : "invalid";
      if (parsed === "invalid") continue;
      byAssessment.set(aid, [...(byAssessment.get(aid) ?? []), { student_id: sid, score: parsed }]);
    }
    let queued = false;
    const refused: string[] = [];
    const kept: Record<string, string> = {};
    for (const [aid, grades] of byAssessment) {
      const a = book.assessments.find((x) => x.id === aid)!;
      const r = await outbox.submit({ method: "PATCH", path: `/assessments/${aid}/grades`, body: { grades }, label: `Scores for ${a.title}` });
      if (r.status === "queued") queued = true;
      else if (r.status === "rejected") {
        refused.push(`${a.title}: ${r.problem?.detail ?? r.problem?.title ?? "not accepted"}`);
        for (const g of grades) kept[`${aid}|${g.student_id}`] = edits[`${aid}|${g.student_id}`]!;
      } else {
        const res = r.body as { results: { student_id: string; outcome: string; message?: string }[] } | null;
        for (const x of res?.results ?? []) {
          if (x.outcome === "rejected") {
            refused.push(`${book.rows.find((row) => row.student.id === x.student_id)?.student.full_name ?? "A student"} (${a.title}): ${x.message ?? "not accepted"}`);
            kept[`${aid}|${x.student_id}`] = edits[`${aid}|${x.student_id}`]!;
          }
        }
      }
    }
    setSaving(false);
    setEdits(queued ? edits : kept);
    if (refused.length) setNote({ tone: "alert", text: `Not saved: ${refused.join("; ")}.` });
    else if (queued) setNote({ tone: "brass", text: "Saved on this device. The scores will sync when you reconnect." });
    else setNote({ tone: "forest", text: "Scores saved." });
    toast(queued ? "Queued for sync" : refused.length ? "Some scores were not accepted" : "Scores saved");
    if (!queued) void qc.invalidateQueries({ queryKey: ["get", "/class_sections/{id}/gradebook"] });
  };

  return (
    <Screen
      withOffline
      eyebrow={`${sel.section?.name ?? ""} · ${sel.subject} · Term`}
      title="Gradebook"
      queries={[q]}
      locked={book?.term_closed}
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
          <Btn onClick={() => go(`/teacher/gradebook/new/${sel.section?.id ?? ""}/${encodeURIComponent(sel.subject)}`)}>New assessment</Btn>
        </>
      }
    >
      {({ locked }) => (
        <>
          {note && <Banner tone={note.tone}>{note.text}</Banner>}
          <Card plain flush>
            <div ref={grid} className="overflow-x-auto">
              <table className="w-full min-w-[720px] border-collapse text-sm">
                <thead>
                  <tr>
                    <th className="eyebrow sticky left-0 z-10 border-b border-rule bg-raised px-3 py-2.5 text-left font-medium">Student</th>
                    {(book?.assessments ?? []).map((a) => (
                      <th key={a.id} className="border-b border-rule px-3 py-2.5 text-left font-medium">
                        <div className="text-sm font-semibold">{a.title}</div>
                        <div className="eyebrow">{a.weight}% · out of {a.max_score}{a.due_date ? ` · ${fmtDay(a.due_date)}` : ""}</div>
                      </th>
                    ))}
                    <th className="eyebrow border-b border-l border-rule px-3 py-2.5 text-right font-medium">Running avg</th>
                  </tr>
                </thead>
                <tbody>
                  {(book?.rows ?? []).map((row, r) => (
                    <tr key={row.student.id} className="border-b border-rule/70 last:border-0 hover:bg-accent-soft">
                      <td className="sticky left-0 bg-raised px-3 py-1.5 font-semibold">{row.student.full_name}</td>
                      {(book?.assessments ?? []).map((a, c) => (
                        <td key={a.id} className="px-2 py-1">
                          <div className="flex items-center gap-1">
                            <input
                              data-cell={`${r}-${c}`}
                              aria-label={`${row.student.full_name}, ${a.title}`}
                              inputMode="decimal"
                              disabled={locked}
                              value={cellValue(a.id, row.student.id, row.scores[a.id])}
                              placeholder="—"
                              onChange={(e) => setEdits({ ...edits, [`${a.id}|${row.student.id}`]: e.target.value })}
                              onKeyDown={(e) => move(e, r, c)}
                              onFocus={(e) => e.target.select()}
                              className="mono h-9 w-16 rounded-reg border border-transparent bg-transparent px-2 text-right hover:border-rule focus:border-accent focus:bg-paper disabled:opacity-60"
                            />
                            <span className="mono text-xs text-mute">/{a.max_score}</span>
                          </div>
                        </td>
                      ))}
                      <td className="mono border-l border-rule px-3 text-right font-semibold">
                        {pct(average(row))}
                        {(() => {
                          const band = gradeBandFor(average(row), bands);
                          return band ? <span className="ml-1.5 text-xs text-mute">({band})</span> : null;
                        })()}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </Card>
          <p className="mt-3 text-xs text-mute">Arrow keys and Enter move between cells. The running average uses only the assessments already scored, and updates as you type.</p>
          <div className="mt-3 flex items-center gap-3">
            <Btn variant="ghost" disabled={locked || saving || dirtyCount === 0} onClick={() => void save()}>{saving ? "Saving…" : "Save scores"}</Btn>
            {dirtyCount > 0 && <span className="text-sm text-mute">{dirtyCount} change{dirtyCount === 1 ? "" : "s"} not saved yet.</span>}
          </div>
        </>
      )}
    </Screen>
  );
}

export function NewAssessment({ sec, subject: initialSubject }: { sec?: string; subject?: string }) {
  const { toast } = useApp();
  const qc = useQueryClient();
  const mine = useMySections();
  const [section, setSection] = useState(sec ?? "");
  const id = section || mine[0]?.id || "";
  const mySection = mine.find((s) => s.id === id);
  const subjects = teachingSubjects(mySection?.subject);
  const [subject, setSubject] = useState(initialSubject ?? "");
  const chosenSubject = subject || subjects[0] || "";
  const [f, setF] = useState({ title: "", weight: "10", max: "20", due: "" });
  const book = $api.useQuery("get", "/class_sections/{id}/gradebook", { params: { path: { id }, query: { subject: chosenSubject } } }, { enabled: !!id && !!chosenSubject });
  const used = (book.data?.assessments ?? []).reduce((sum, a) => sum + a.weight, 0);
  const weight = Number(f.weight);
  const max = Number(f.max);
  const valid = f.title.trim() && weight > 0 && weight <= 100 - used && max > 0 && chosenSubject;
  const create = $api.useMutation("post", "/class_sections/{id}/assessments", {
    onSuccess: () => {
      toast("Assessment added");
      void qc.invalidateQueries({ queryKey: ["get", "/class_sections/{id}/gradebook"] });
      go("/teacher/gradebook");
    },
    onError: (e) => toast(errorMessage(e)),
  });
  return (
    <Screen eyebrow="Gradebook" title="New assessment" narrow queries={[]} locked={book.data?.term_closed}>
      {({ locked }) => (
        <Card>
          <div className="grid gap-4 sm:grid-cols-2">
            <Field label="Title" className="sm:col-span-2"><input className={inputCls} value={f.title} onChange={(e) => setF({ ...f, title: e.target.value })} placeholder="Decimals quiz" /></Field>
            <Field label="Section">
              <select className={inputCls} value={id} onChange={(e) => setSection(e.target.value)}>
                {mine.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
              </select>
            </Field>
            <Field label="Subject">
              <select className={inputCls} value={chosenSubject} onChange={(e) => setSubject(e.target.value)}>
                {subjects.map((s) => <option key={s}>{s}</option>)}
              </select>
            </Field>
            <Field label="Weight (%)"><input className={inputCls + " mono"} inputMode="decimal" value={f.weight} onChange={(e) => setF({ ...f, weight: e.target.value })} /></Field>
            <Field label="Out of"><input className={inputCls + " mono"} inputMode="decimal" value={f.max} onChange={(e) => setF({ ...f, max: e.target.value })} /></Field>
            <Field label="Due date"><input type="date" className={inputCls} value={f.due} onChange={(e) => setF({ ...f, due: e.target.value })} /></Field>
          </div>
          <p className={`mt-3 text-sm ${weight > 100 - used ? "text-alert" : "text-mute"}`}>
            {chosenSubject} weights currently total {used}%. {100 - used > 0 ? `You can add up to ${100 - used}% more.` : "There is no weight left to assign: lower another assessment first."}
          </p>
          <div className="mt-4 flex gap-2">
            <Btn disabled={locked || !valid || create.isPending} onClick={() => create.mutate({ params: { path: { id } }, body: { subject: chosenSubject, title: f.title.trim(), weight, max_score: max, ...(f.due ? { due_date: f.due } : {}) } })}>Add assessment</Btn>
            <Btn variant="ghost" onClick={() => go("/teacher/gradebook")}>Cancel</Btn>
          </div>
        </Card>
      )}
    </Screen>
  );
}
