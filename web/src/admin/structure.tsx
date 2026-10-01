import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { $api } from "../api/client";
import { errorMessage } from "../api/errors";
import { useMe } from "../auth/auth";
import { fmtDay } from "../lib/format";
import { Btn, Card, DataTable, Field, inputCls, Screen, Tabs, Tag, useApp } from "../ui";
import { useSections } from "./shared";

const days = ["Mon", "Tue", "Wed", "Thu", "Fri"];

export function Sections() {
  const { toast } = useApp();
  const me = useMe();
  const qc = useQueryClient();
  const { q, sections } = useSections();
  const [open, setOpen] = useState("");
  const [adding, setAdding] = useState(false);
  const [draft, setDraft] = useState({ name: "", grade: "" });
  const selected = open || sections[0]?.id || "";
  const detail = $api.useQuery("get", "/class_sections/{id}", { params: { path: { id: selected } } }, { enabled: !!selected });
  const teachers = $api.useQuery("get", "/people", { params: { query: { role: "teacher", limit: 200 } } });
  const refresh = () => void qc.invalidateQueries({ queryKey: ["get", "/class_sections"] });
  const patch = $api.useMutation("patch", "/class_sections/{id}", {
    onSuccess: () => { toast("Homeroom teacher updated"); refresh(); },
    onError: (e) => toast(errorMessage(e)),
  });
  const create = $api.useMutation("post", "/class_sections", {
    onSuccess: () => { toast("Section created"); setAdding(false); setDraft({ name: "", grade: "" }); refresh(); },
    onError: (e) => toast(errorMessage(e)),
  });
  const d = detail.data;
  return (
    <Screen
      eyebrow="Structure"
      title="Class sections"
      queries={[q]}
      empty={sections.length === 0 && !adding}
      emptyText="No sections exist for this term yet."
      actions={<Btn onClick={() => setAdding(true)}>New section</Btn>}
    >
      {() => (
        <div className="space-y-5">
          {adding && (
            <Card title="New section" eyebrow={me.school.term?.name}>
              <div className="grid gap-4 sm:grid-cols-3">
                <Field label="Name"><input className={inputCls} value={draft.name} onChange={(e) => setDraft({ ...draft, name: e.target.value })} placeholder="5A" /></Field>
                <Field label="Grade"><input className={inputCls} value={draft.grade} onChange={(e) => setDraft({ ...draft, grade: e.target.value })} placeholder="5" /></Field>
                <div className="flex items-end gap-2">
                  <Btn
                    disabled={!draft.name || !draft.grade || !me.school.term || create.isPending}
                    onClick={() => create.mutate({ body: { name: draft.name, grade_level: draft.grade, term_id: me.school.term!.id, homeroom_teacher_id: null } })}
                  >
                    Create
                  </Btn>
                  <Btn variant="ghost" onClick={() => setAdding(false)}>Cancel</Btn>
                </div>
              </div>
            </Card>
          )}
          <div className="grid gap-5 lg:grid-cols-[2fr_3fr]">
            <Card plain flush>
              <DataTable
                onRow={(s) => setOpen(s.id)}
                cols={[
                  { key: "name", label: "Section", mono: true, render: (s) => <b className={selected === s.id ? "text-accent" : ""}>{s.name}</b> },
                  { key: "grade_level", label: "Grade", mono: true },
                  { key: "homeroom", label: "Homeroom", render: (s) => s.homeroom_teacher?.full_name ?? <Tag tone="brass">Unassigned</Tag> },
                ]}
                rows={sections}
              />
            </Card>
            <Card
              title={`Roster, ${d?.name ?? ""}`}
              eyebrow={`${d?.roster?.length ?? 0} students`}
              actions={
                d && (
                  <select
                    aria-label="Homeroom teacher"
                    className={inputCls + " w-auto"}
                    value={d.homeroom_teacher?.id ?? ""}
                    disabled={patch.isPending}
                    onChange={(e) => patch.mutate({ params: { path: { id: d.id! } }, body: { homeroom_teacher_id: e.target.value || null } })}
                  >
                    <option value="">Unassigned</option>
                    {(teachers.data?.items ?? []).map((t) => (
                      <option key={t.id} value={t.id}>{t.full_name}</option>
                    ))}
                  </select>
                )
              }
            >
              {detail.isPending ? (
                <p className="text-mute">Loading…</p>
              ) : (
                <ul className="columns-1 gap-6 text-sm sm:columns-2">
                  {(d?.roster ?? []).map((s) => (
                    <li key={s.id} className="border-b border-rule/70 py-1.5">{s.full_name}</li>
                  ))}
                </ul>
              )}
            </Card>
          </div>
        </div>
      )}
    </Screen>
  );
}

export function Staff() {
  const teachers = $api.useQuery("get", "/people", { params: { query: { role: "teacher", limit: 200 } } });
  const admins = $api.useQuery("get", "/people", { params: { query: { role: "admin", limit: 50 } } });
  const rows = [...(admins.data?.items ?? []), ...(teachers.data?.items ?? [])];
  const [sel, setSel] = useState("");
  const cur = rows.find((r) => r.id === sel) ?? rows[0];
  type Row = (typeof rows)[number];
  const subjects = (p?: Row) => [...new Set((p?.assignments ?? []).map((a) => a.subject).filter((s) => s !== "Homeroom"))].join(", ");
  const homeroom = (p?: Row) => (p?.assignments ?? []).filter((a) => a.subject === "Homeroom").map((a) => a.class_section?.name).join(", ");
  const roleLabel = (p: Row) => (p.role === "admin" ? "Registrar" : "Teacher");
  return (
    <Screen eyebrow="People" title="Staff" queries={[teachers, admins]} empty={rows.length === 0} emptyText="No staff records.">
      {() => (
        <div className="grid gap-5 lg:grid-cols-[3fr_2fr]">
          <Card plain flush>
            <DataTable
              onRow={(s) => setSel(s.id)}
              cols={[
                { key: "full_name", label: "Name", render: (s) => <b>{s.full_name}</b> },
                { key: "role", label: "Role", render: roleLabel },
                { key: "subjects", label: "Subjects", render: (s) => subjects(s) || "n/a" },
                { key: "homeroom", label: "Homeroom", render: (s) => homeroom(s) || "None" },
              ]}
              rows={rows}
            />
          </Card>
          {cur && (
            <Card title={cur.full_name} eyebrow="Staff record">
              <dl className="space-y-2 text-sm">
                {[
                  ["Role", roleLabel(cur)],
                  ["Subjects", subjects(cur) || "n/a"],
                  ["Homeroom", homeroom(cur) || "None"],
                  ["Email", cur.contact?.email ?? "n/a"],
                  ["Phone", cur.contact?.phone ?? "n/a"],
                ].map(([k, v]) => (
                  <div key={k} className="flex justify-between gap-4 border-b border-rule/70 pb-1.5">
                    <dt className="eyebrow self-center">{k}</dt>
                    <dd className="text-right">{v}</dd>
                  </div>
                ))}
              </dl>
              <p className="mt-3 text-xs text-mute">Payroll arrives in Term 3.</p>
            </Card>
          )}
        </div>
      )}
    </Screen>
  );
}

function GradingTab() {
  const { toast } = useApp();
  const qc = useQueryClient();
  const bands = $api.useQuery("get", "/grade_bands");
  const [draft, setDraft] = useState({ label: "", min: "", max: "" });
  const refresh = () => void qc.invalidateQueries({ queryKey: ["get", "/grade_bands"] });
  const create = $api.useMutation("post", "/grade_bands", {
    onSuccess: () => { toast("Band added"); setDraft({ label: "", min: "", max: "" }); refresh(); },
    onError: (e) => toast(errorMessage(e)),
  });
  const remove = $api.useMutation("delete", "/grade_bands/{id}", {
    onSuccess: () => { toast("Band removed"); refresh(); },
    onError: (e) => toast(errorMessage(e)),
  });
  const min = Number(draft.min);
  const max = Number(draft.max);
  const valid = draft.label.trim() && draft.min !== "" && draft.max !== "" && min <= max;
  const items = bands.data?.items ?? [];
  return (
    <Card title="Grading scale" eyebrow={items.length === 0 ? "None configured: running grades show as bare numbers" : "Applied to every running grade in this school"}>
      {items.length > 0 && (
        <ul className="mb-4 divide-y divide-rule text-sm">
          {items.map((b) => (
            <li key={b.id} className="flex items-center justify-between gap-3 py-2">
              <span><b className="mono">{b.label}</b> <span className="text-mute">{b.min_score}–{b.max_score}</span></span>
              <Btn variant="ghost" disabled={remove.isPending} onClick={() => remove.mutate({ params: { path: { id: b.id } } })}>Remove</Btn>
            </li>
          ))}
        </ul>
      )}
      <div className="grid gap-4 sm:grid-cols-4">
        <Field label="Label"><input className={inputCls} value={draft.label} onChange={(e) => setDraft({ ...draft, label: e.target.value })} placeholder="A" /></Field>
        <Field label="Min score"><input className={inputCls + " mono"} inputMode="decimal" value={draft.min} onChange={(e) => setDraft({ ...draft, min: e.target.value })} placeholder="80" /></Field>
        <Field label="Max score"><input className={inputCls + " mono"} inputMode="decimal" value={draft.max} onChange={(e) => setDraft({ ...draft, max: e.target.value })} placeholder="100" /></Field>
        <div className="flex items-end">
          <Btn disabled={!valid || create.isPending} onClick={() => create.mutate({ body: { label: draft.label.trim(), min_score: min, max_score: max } })}>Add band</Btn>
        </div>
      </div>
    </Card>
  );
}

export function Timetable() {
  const { q: secQ, sections } = useSections();
  const [sec, setSec] = useState("");
  const [tab, setTab] = useState("Weekly grid");
  const selected = sec || sections[0]?.id || "";
  const periods = $api.useQuery("get", "/class_sections/{id}/periods", { params: { path: { id: selected } } }, { enabled: !!selected });
  const terms = $api.useQuery("get", "/terms");
  const items = periods.data?.items ?? [];
  const slots = [...new Map(items.map((p) => [`${p.starts_at}-${p.ends_at}`, { start: p.starts_at!, end: p.ends_at! }])).values()].sort((a, b) => a.start.localeCompare(b.start));
  const cell = (start: string, weekday: number) => items.filter((p) => p.starts_at === start && p.weekday === weekday);
  return (
    <Screen eyebrow="Schedule" title="Timetable and calendar" queries={[secQ]}>
      {() => (
        <>
          <Tabs tabs={["Weekly grid", "Terms", "Grading"]} value={tab} onChange={setTab} />
          {tab === "Weekly grid" ? (
            <Card
              title={`Section ${sections.find((s) => s.id === selected)?.name ?? ""}`}
              actions={
                <select aria-label="Section" value={selected} onChange={(e) => setSec(e.target.value)} className={inputCls + " w-auto"}>
                  {sections.map((s) => (
                    <option key={s.id} value={s.id}>{s.name}</option>
                  ))}
                </select>
              }
              flush
            >
              {periods.isPending ? (
                <p className="p-4 text-mute">Loading…</p>
              ) : slots.length === 0 ? (
                <p className="p-4 text-mute">No timetable has been set for this section.</p>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full min-w-[560px] border-collapse text-sm">
                    <thead>
                      <tr>
                        <th className="eyebrow p-2 text-left font-medium">Time</th>
                        {days.map((d) => (
                          <th key={d} className="eyebrow p-2 text-left font-medium">{d}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {slots.map((t) => (
                        <tr key={t.start} className="border-t border-rule/70">
                          <td className="mono p-2 text-xs text-mute">{t.start} to {t.end}</td>
                          {days.map((_, j) => (
                            <td key={j} className="p-2">
                              {cell(t.start, j + 1).map((c) => (
                                <div key={c.id}>
                                  <span className="font-semibold text-accent">{c.subject}</span> <span className="text-xs text-mute">{c.teacher?.full_name?.split(" ").pop()}</span>
                                </div>
                              ))}
                            </td>
                          ))}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </Card>
          ) : tab === "Terms" ? (
            <Card title="Terms" eyebrow="Calendar">
              <ul className="divide-y divide-rule text-sm">
                {(terms.data?.items ?? []).map((t) => (
                  <li key={t.id} className="flex flex-wrap items-center gap-4 py-2">
                    <span className="w-28 font-semibold">{t.name}</span>
                    <span className="mono text-mute">{fmtDay(t.starts_on)} to {fmtDay(t.ends_on)}</span>
                    {t.closed && <Tag>Closed</Tag>}
                  </li>
                ))}
              </ul>
            </Card>
          ) : (
            <GradingTab />
          )}
        </>
      )}
    </Screen>
  );
}
