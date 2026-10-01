import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { $api } from "../api/client";
import { errorMessage } from "../api/errors";
import { useMe } from "../auth/auth";
import { fmtDay, fmtStamp, money, pct } from "../lib/format";
import { allItems, cursorPaging, useDebounced } from "../lib/hooks";
import { Btn, Card, DataTable, Field, inputCls, invTone, Link, Screen, Tag, go, useApp } from "../ui";
import { LoadMore, cap, invoiceLabel, useSections } from "./shared";

export function Students() {
  const [q, setQ] = useState("");
  const [sec, setSec] = useState("");
  const [grade, setGrade] = useState("");
  const debounced = useDebounced(q);
  const { sections } = useSections();
  const list = $api.useInfiniteQuery(
    "get",
    "/students",
    { params: { query: { limit: 50, ...(debounced ? { q: debounced } : {}), ...(sec ? { class_section_id: sec } : {}), ...(grade ? { grade_level: grade } : {}) } } },
    cursorPaging,
  );
  const rows = allItems(list.data);
  const grades = [...new Set(sections.map((s) => s.grade_level))].sort();
  return (
    <Screen eyebrow="Register" title="Students" queries={[list]} empty={rows.length === 0 && !debounced && !sec && !grade} emptyText="No students have been enrolled for this term.">
      {() => (
        <Card plain flush>
          <div className="flex flex-wrap gap-3 border-b border-rule p-3">
            <input aria-label="Search students" value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search by name" className={inputCls + " max-w-xs"} />
            <select aria-label="Grade" value={grade} onChange={(e) => setGrade(e.target.value)} className={inputCls + " w-auto"}>
              <option value="">All grades</option>
              {grades.map((g) => (
                <option key={g} value={g}>Grade {g}</option>
              ))}
            </select>
            <select aria-label="Section" value={sec} onChange={(e) => setSec(e.target.value)} className={inputCls + " w-auto"}>
              <option value="">All sections</option>
              {sections.map((s) => (
                <option key={s.id} value={s.id}>{s.name}</option>
              ))}
            </select>
            <span className="mono ml-auto self-center text-xs text-mute">{rows.length} shown{list.hasNextPage ? "+" : ""}</span>
          </div>
          {rows.length === 0 ? (
            <p className="p-8 text-center text-mute">No students match these filters.</p>
          ) : (
            <DataTable
              onRow={(s) => go("/admin/students/" + s.id)}
              cols={[
                { key: "full_name", label: "Name", render: (s) => <span className="font-semibold">{s.full_name}</span> },
                { key: "section", label: "Section", mono: true, render: (s) => s.class_section?.name ?? "Not placed" },
                { key: "guardians", label: "Guardians", render: (s) => (s.guardian_names ?? []).join(", ") || <span className="text-mute">None linked</span> },
                { key: "att", label: "Attendance", mono: true, align: "right", render: (s) => pct(s.attendance_rate_pct) },
              ]}
              rows={rows}
            />
          )}
          <LoadMore q={list} />
        </Card>
      )}
    </Screen>
  );
}

export function StudentProfile({ id }: { id: string }) {
  const me = useMe();
  const s = $api.useQuery("get", "/students/{id}", { params: { path: { id } } });
  const inv = $api.useQuery("get", "/students/{id}/invoices", { params: { path: { id } } });
  const audit = $api.useQuery("get", "/audit_log", { params: { query: { student_id: id, limit: 5 } } });
  const st = s.data;
  const guardians = st?.guardians ?? [];
  return (
    <Screen
      eyebrow={st?.class_section ? `Section ${st.class_section.name}` : "Student"}
      title={st?.full_name ?? "Student"}
      narrow
      queries={[s, inv]}
      actions={<Link to="/admin/students" className="text-sm font-semibold text-accent">All students</Link>}
    >
      {() => (
        <div className="space-y-5">
          <div className="grid gap-5 md:grid-cols-2">
            <Card title="Guardians" eyebrow={guardians.length > 1 ? "Two guardians on record" : "Guardian"}>
              {guardians.length === 0 ? (
                <p className="text-mute">No guardian is linked yet.</p>
              ) : (
                <ul className="space-y-3">
                  {guardians.map((g) => (
                    <li key={g.guardian?.id}>
                      <div className="font-semibold">
                        {g.guardian?.full_name} <span className="text-sm font-normal text-mute">({g.relationship})</span> {g.is_primary_contact && <Tag tone="accent">Primary</Tag>}
                      </div>
                      <div className="mono text-xs text-mute">
                        {g.guardian?.contact?.phone ?? "No phone"}
                        {g.guardian?.contact?.email ? ` · ${g.guardian.contact.email}` : ""}
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </Card>
            <Card title="Enrollment history">
              <ul className="space-y-2 text-sm">
                {(st?.enrollments ?? []).map((e) => (
                  <li key={e.id} className="flex justify-between">
                    <span>{e.term_name}: {e.class_section_name}</span>
                    {e.status === "active" ? <Tag tone="forest">Current</Tag> : <span className="mono text-mute">{cap(e.status)}</span>}
                  </li>
                ))}
              </ul>
              <Btn variant="ghost" className="mt-3" onClick={() => go("/admin/enrollment")}>Change section</Btn>
            </Card>
          </div>
          <Card title="Invoices" flush>
            {(inv.data?.items ?? []).length === 0 ? (
              <p className="p-4 text-mute">No invoices for this student.</p>
            ) : (
              <DataTable
                cols={[
                  { key: "description", label: "Item" },
                  { key: "due_date", label: "Due", mono: true, render: (i) => fmtDay(i.due_date) },
                  { key: "amount_due", label: "Total", mono: true, align: "right", render: (i) => money(i.amount_due) },
                  { key: "outstanding", label: "Balance", mono: true, align: "right", render: (i) => money(i.outstanding) },
                  { key: "status", label: "Status", render: (i) => <Tag tone={invTone(invoiceLabel(i))}>{invoiceLabel(i)}</Tag> },
                ]}
                rows={inv.data?.items ?? []}
              />
            )}
          </Card>
          <Card title="Who viewed this record" eyebrow="Audit">
            {(audit.data?.items ?? []).length === 0 ? (
              <p className="text-sm text-mute">No views recorded yet.</p>
            ) : (
              <ul className="divide-y divide-rule text-sm">
                {audit.data!.items!.map((a) => (
                  <li key={a.id} className="flex flex-wrap justify-between gap-2 py-2">
                    <span>
                      <b>{a.actor?.full_name}</b> ({a.actor?.role === "guardian" ? "parent" : a.actor?.role}) viewed: {a.table_name.replace("student_", "").replace("_", " ")}
                    </span>
                    <span className="mono text-xs text-mute">{fmtStamp(a.at, me.school.timezone)}</span>
                  </li>
                ))}
              </ul>
            )}
          </Card>
        </div>
      )}
    </Screen>
  );
}

export function Enrollment() {
  const { toast } = useApp();
  const qc = useQueryClient();
  const [search, setSearch] = useState("");
  const debounced = useDebounced(search);
  const [stu, setStu] = useState("");
  const [sec, setSec] = useState("");
  const { q: secQ, sections } = useSections();
  const found = $api.useQuery("get", "/students", { params: { query: { limit: 30, ...(debounced ? { q: debounced } : {}) } } });
  const students = found.data?.items ?? [];
  const enrol = $api.useMutation("post", "/enrollments", {
    onSuccess: () => {
      toast("Enrollment saved and written to the audit log");
      void qc.invalidateQueries({ queryKey: ["get", "/students"] });
      void qc.invalidateQueries({ queryKey: ["get", "/class_sections"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });

  const [bulkSec, setBulkSec] = useState("");
  const [names, setNames] = useState("");
  const [imported, setImported] = useState<string[] | null>(null);
  const parsed = [...new Set(names.split("\n").map((n) => n.trim()).filter(Boolean))];
  const bulkImport = $api.useMutation("post", "/class_sections/{id}/students/import", {
    onSuccess: (r) => {
      setImported((r.items ?? []).map((s) => s.full_name));
      setNames("");
      toast(`${r.items?.length ?? 0} students added`);
      void qc.invalidateQueries({ queryKey: ["get", "/students"] });
      void qc.invalidateQueries({ queryKey: ["get", "/class_sections"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });

  return (
    <Screen eyebrow="Register" title="Enrollment" narrow queries={[secQ]}>
      {({ locked }) => (
        <div className="space-y-5">
          <Card title="Assign a student to a section">
            <div className="grid gap-4 sm:grid-cols-2">
              <Field label="Find student"><input className={inputCls} value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Type a name" /></Field>
              <Field label="Section">
                <select className={inputCls} value={sec} onChange={(e) => setSec(e.target.value)}>
                  <option value="">Choose a section</option>
                  {sections.map((s) => (
                    <option key={s.id} value={s.id}>{s.name}</option>
                  ))}
                </select>
              </Field>
              <Field label="Student" className="sm:col-span-2">
                <select className={inputCls} size={Math.min(6, Math.max(2, students.length))} value={stu} onChange={(e) => setStu(e.target.value)}>
                  {students.map((s) => (
                    <option key={s.id} value={s.id}>{s.full_name} ({s.class_section?.name ?? "not placed"})</option>
                  ))}
                </select>
              </Field>
            </div>
            <Btn className="mt-4" disabled={locked || !stu || !sec || enrol.isPending} onClick={() => enrol.mutate({ body: { student_id: stu, class_section_id: sec } })}>
              Save assignment
            </Btn>
          </Card>
          <Card title="Bulk import" eyebrow="New students, one per line">
            <p className="text-sm text-soft">Paste a list of names (one per line) to create new students and enrol them all in one section. Each becomes a new student record: this does not match against existing pupils.</p>
            <div className="mt-3 grid gap-4 sm:grid-cols-2">
              <Field label="Section">
                <select className={inputCls} value={bulkSec} onChange={(e) => setBulkSec(e.target.value)}>
                  <option value="">Choose a section</option>
                  {sections.map((s) => (
                    <option key={s.id} value={s.id}>{s.name}</option>
                  ))}
                </select>
              </Field>
              <div className="flex items-end text-sm text-mute">{parsed.length > 0 ? `${parsed.length} name${parsed.length === 1 ? "" : "s"} ready` : " "}</div>
              <Field label="Names" className="sm:col-span-2">
                <textarea
                  className={inputCls + " min-h-0 resize-y py-2"}
                  rows={5}
                  value={names}
                  onChange={(e) => { setNames(e.target.value); setImported(null); }}
                  placeholder={"Ama Boateng\nKwesi Owusu\n…"}
                />
              </Field>
            </div>
            <Btn
              className="mt-4"
              disabled={locked || !bulkSec || parsed.length === 0 || bulkImport.isPending}
              onClick={() => bulkImport.mutate({ params: { path: { id: bulkSec } }, body: { students: parsed.map((full_name) => ({ full_name })) } })}
            >
              {bulkImport.isPending ? "Importing…" : `Import ${parsed.length || ""} student${parsed.length === 1 ? "" : "s"}`}
            </Btn>
            {imported && imported.length > 0 && <p className="mt-3 text-sm text-forest">Added: {imported.join(", ")}.</p>}
          </Card>
        </div>
      )}
    </Screen>
  );
}
