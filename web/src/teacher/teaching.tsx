import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { $api } from "../api/client";
import { errorMessage } from "../api/errors";
import { useMe } from "../auth/auth";
import { fmtDay, fmtDayWeekday } from "../lib/format";
import { zonedToIso } from "../lib/tz";
import { Conversations } from "../pages/messages";
import { Btn, Card, Field, inputCls, Screen, Tag, useApp } from "../ui";
import { useMySections } from "./shared";

export function Homework() {
  const { toast } = useApp();
  const qc = useQueryClient();
  const mine = useMySections();
  const [section, setSection] = useState("");
  const id = section || mine[0]?.id || "";
  const list = $api.useQuery("get", "/class_sections/{id}/homework", { params: { path: { id } } }, { enabled: !!id });
  const [f, setF] = useState({ title: "", body: "", due: "" });
  const post = $api.useMutation("post", "/class_sections/{id}/homework", {
    onSuccess: () => {
      toast("Homework posted to guardians");
      setF({ title: "", body: "", due: "" });
      void qc.invalidateQueries({ queryKey: ["get", "/class_sections/{id}/homework"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });
  const items = list.data?.items ?? [];
  return (
    <Screen eyebrow="Teaching" title="Homework" queries={[list]} empty={mine.length === 0} emptyText="You are not assigned to any class this term.">
      {({ locked }) => (
        <div className="grid gap-5 lg:grid-cols-[2fr_3fr]">
          <Card title="Post homework">
            <div className="space-y-3">
              <Field label="Task"><input className={inputCls} value={f.title} onChange={(e) => setF({ ...f, title: e.target.value })} placeholder="Exercises 4.6 to 4.8" /></Field>
              <Field label="Details (optional)"><textarea rows={2} className={inputCls + " py-2"} value={f.body} onChange={(e) => setF({ ...f, body: e.target.value })} /></Field>
              <div className="grid grid-cols-2 gap-3">
                <Field label="Section">
                  <select className={inputCls} value={id} onChange={(e) => setSection(e.target.value)}>
                    {mine.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
                  </select>
                </Field>
                <Field label="Due"><input type="date" className={inputCls} value={f.due} onChange={(e) => setF({ ...f, due: e.target.value })} /></Field>
              </div>
              <Btn
                disabled={locked || !f.title.trim() || !f.due || post.isPending}
                onClick={() => post.mutate({ params: { path: { id } }, body: { title: f.title.trim(), due_date: f.due, ...(f.body.trim() ? { body: f.body.trim() } : {}) } })}
              >
                Post
              </Btn>
            </div>
          </Card>
          <Card title="Posted" flush>
            {items.length === 0 ? (
              <p className="p-4 text-mute">No homework has been posted for this class.</p>
            ) : (
              <ul className="divide-y divide-rule">
                {items.map((h) => (
                  <li key={h.id} className="px-4 py-3">
                    <div className="font-semibold">{h.title}</div>
                    <div className="eyebrow">{h.subject ?? "Homeroom"} · due {fmtDay(h.due_date)}</div>
                    {h.body && <p className="mt-1 text-sm text-soft">{h.body}</p>}
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

/** Start a conversation: pick a class, a pupil, then a guardian of that pupil. */
function NewConversation() {
  const { toast } = useApp();
  const qc = useQueryClient();
  const mine = useMySections();
  const [sec, setSec] = useState("");
  const [stu, setStu] = useState("");
  const id = sec || mine[0]?.id || "";
  const roster = $api.useQuery("get", "/students", { params: { query: { class_section_id: id, limit: 100 } } }, { enabled: !!id });
  const student = $api.useQuery("get", "/students/{id}", { params: { path: { id: stu } } }, { enabled: !!stu });
  const open = $api.useMutation("post", "/threads", {
    onSuccess: () => {
      toast("Conversation opened");
      setStu("");
      void qc.invalidateQueries({ queryKey: ["get", "/threads"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });
  const guardians = student.data?.guardians ?? [];
  return (
    <Card title="New conversation" eyebrow="About one pupil">
      <div className="space-y-3">
        <Field label="Class">
          <select className={inputCls} value={id} onChange={(e) => { setSec(e.target.value); setStu(""); }}>
            {mine.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
          </select>
        </Field>
        <Field label="Pupil">
          <select className={inputCls} value={stu} onChange={(e) => setStu(e.target.value)}>
            <option value="">Choose</option>
            {(roster.data?.items ?? []).map((s) => <option key={s.id} value={s.id}>{s.full_name}</option>)}
          </select>
        </Field>
        {stu && student.isPending && <p className="text-sm text-mute">Loading guardians…</p>}
        {stu && guardians.length === 0 && !student.isPending && <p className="text-sm text-mute">No guardian is linked to this pupil yet. Ask the office.</p>}
        <div className="flex flex-wrap gap-2">
          {guardians.map((g) => (
            <Btn key={g.guardian.id} variant="ghost" disabled={open.isPending} onClick={() => open.mutate({ body: { student_id: stu, other_party_id: g.guardian.id } })}>
              Message {g.guardian.full_name} <span className="text-mute">({g.relationship})</span>
            </Btn>
          ))}
        </div>
      </div>
    </Card>
  );
}

export function Messages() {
  return <Conversations compose={<NewConversation />} />;
}

export function Conferences() {
  const me = useMe();
  const tz = me.school.timezone;
  const { toast } = useApp();
  const qc = useQueryClient();
  const slots = $api.useQuery("get", "/conference_slots");
  const [form, setForm] = useState({ date: "", from: "09:00", to: "12:00", minutes: "15" });
  const create = $api.useMutation("post", "/conference_slots", {
    onSuccess: (r) => {
      toast(`${r.items.length} slots created`);
      void qc.invalidateQueries({ queryKey: ["get", "/conference_slots"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });
  const byDay = new Map<string, NonNullable<typeof slots.data>["items"]>();
  for (const s of slots.data?.items ?? []) byDay.set(s.starts_at.slice(0, 10), [...(byDay.get(s.starts_at.slice(0, 10)) ?? []), s]);
  const hhmm = (iso: string) => new Intl.DateTimeFormat("en-GB", { hour: "2-digit", minute: "2-digit", timeZone: tz }).format(new Date(iso));
  const valid = form.date && form.from < form.to && Number(form.minutes) >= 5;
  return (
    <Screen eyebrow="Schedule" title="Conference schedule" queries={[slots]}>
      {() => (
        <div className="grid gap-5 lg:grid-cols-[2fr_3fr]">
          <Card title="Open slots">
            <div className="space-y-3">
              <Field label="Date"><input type="date" className={inputCls} value={form.date} onChange={(e) => setForm({ ...form, date: e.target.value })} /></Field>
              <div className="grid grid-cols-3 gap-3">
                <Field label="From"><input type="time" className={inputCls} value={form.from} onChange={(e) => setForm({ ...form, from: e.target.value })} /></Field>
                <Field label="To"><input type="time" className={inputCls} value={form.to} onChange={(e) => setForm({ ...form, to: e.target.value })} /></Field>
                <Field label="Minutes"><input className={inputCls} inputMode="numeric" value={form.minutes} onChange={(e) => setForm({ ...form, minutes: e.target.value })} /></Field>
              </div>
              <Btn
                disabled={!valid || create.isPending}
                onClick={() => create.mutate({ body: { teacher_id: me.id, starts_at: zonedToIso(form.date, form.from, tz), ends_at: zonedToIso(form.date, form.to, tz), slot_minutes: Number(form.minutes) } })}
              >
                Create slots
              </Btn>
            </div>
          </Card>
          <div className="space-y-4">
            {byDay.size === 0 && <p className="rounded-reg border border-dashed border-rule p-8 text-center text-mute">You have not opened any conference slots.</p>}
            {[...byDay.entries()].map(([day, list]) => (
              <Card key={day} title={fmtDayWeekday(day)} eyebrow={`${list.filter((s) => s.booked).length} of ${list.length} booked`} flush>
                <ul className="divide-y divide-rule">
                  {list.map((s) => (
                    <li key={s.id} className="flex items-center gap-4 px-4 py-2.5">
                      <span className="mono w-14 font-semibold">{hhmm(s.starts_at)}</span>
                      {s.booked ? (
                        <>
                          <span className="flex-1">{s.student?.full_name ?? "Booked"}</span>
                          <Tag tone="accent">Booked</Tag>
                        </>
                      ) : (
                        <span className="flex-1 text-mute">Open</span>
                      )}
                    </li>
                  ))}
                </ul>
              </Card>
            ))}
          </div>
        </div>
      )}
    </Screen>
  );
}

