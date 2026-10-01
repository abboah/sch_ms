import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { $api } from "../api/client";
import { errorMessage } from "../api/errors";
import { useMe } from "../auth/auth";
import { fmtDayWeekday, fmtStamp } from "../lib/format";
import { allItems, cursorPaging } from "../lib/hooks";
import { zonedToIso } from "../lib/tz";
import { Btn, Card, Field, inputCls, MessageThread, Screen, useApp } from "../ui";
import { useSections } from "./shared";

function Tally({ id }: { id: string }) {
  const q = $api.useQuery("get", "/announcements/{id}/responses", { params: { path: { id } } });
  if (!q.data) return null;
  const { yes = 0, no = 0, awaiting = 0 } = q.data;
  const total = Math.max(1, yes + no + awaiting);
  return (
    <div className="mt-3">
      <div className="eyebrow mb-1">Responses, {yes + no + awaiting} children</div>
      <div className="flex h-3 overflow-hidden rounded-reg border border-rule">
        <i className="bg-forest" style={{ width: (yes / total) * 100 + "%" }} />
        <i className="bg-alert" style={{ width: (no / total) * 100 + "%" }} />
      </div>
      <div className="mono mt-1 text-xs text-mute">{yes} yes · {no} no · {awaiting} waiting</div>
    </div>
  );
}

export function Announcements() {
  const { toast } = useApp();
  const me = useMe();
  const qc = useQueryClient();
  const { sections } = useSections();
  const list = $api.useInfiniteQuery("get", "/announcements", { params: { query: { limit: 20 } } }, cursorPaging);
  const rows = allItems(list.data);
  const [f, setF] = useState({ title: "", body: "", audience: "", slip: false });
  const create = $api.useMutation("post", "/announcements", {
    onSuccess: () => {
      toast("Sent");
      setF({ title: "", body: "", audience: "", slip: false });
      void qc.invalidateQueries({ queryKey: ["get", "/announcements"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });
  return (
    <Screen eyebrow="Communication" title="Announcements and permission slips" queries={[list]}>
      {({ locked }) => (
        <div className="grid gap-5 lg:grid-cols-[2fr_3fr]">
          <Card title="Compose">
            <div className="space-y-3">
              <Field label="Title"><input className={inputCls} value={f.title} onChange={(e) => setF({ ...f, title: e.target.value })} /></Field>
              <Field label="Audience">
                <select className={inputCls} value={f.audience} onChange={(e) => setF({ ...f, audience: e.target.value })}>
                  <option value="">Every guardian</option>
                  {sections.map((s) => (
                    <option key={s.id} value={s.id}>Section {s.name}</option>
                  ))}
                </select>
              </Field>
              <Field label="Message"><textarea rows={4} className={inputCls + " py-2"} value={f.body} onChange={(e) => setF({ ...f, body: e.target.value })} /></Field>
              <label className="flex items-center gap-2 text-sm">
                <input type="checkbox" checked={f.slip} onChange={(e) => setF({ ...f, slip: e.target.checked })} className="h-4 w-4 accent-[var(--accent)]" /> Require a permission slip response
              </label>
              <Btn
                disabled={locked || !f.title.trim() || !f.body.trim() || create.isPending}
                onClick={() => create.mutate({ body: { title: f.title, body: f.body, class_section_id: f.audience || null, requires_response: f.slip, published: true } })}
              >
                Send
              </Btn>
            </div>
          </Card>
          <div className="space-y-4">
            {rows.length === 0 && <p className="rounded-reg border border-dashed border-rule p-8 text-center text-mute">No announcements yet.</p>}
            {rows.map((a) => (
              <Card
                key={a.id}
                title={a.title}
                eyebrow={`${a.published_at ? fmtStamp(a.published_at, me.school.timezone) : "Draft"} · ${a.class_section_id ? (sections.find((s) => s.id === a.class_section_id)?.name ?? "One class") : "Every guardian"}`}
              >
                <p className="text-sm text-soft">{a.body}</p>
                {a.requires_response && a.published_at && <Tally id={a.id!} />}
              </Card>
            ))}
            {list.hasNextPage && (
              <div className="text-center"><Btn variant="ghost" onClick={() => void list.fetchNextPage()}>Load more</Btn></div>
            )}
          </div>
        </div>
      )}
    </Screen>
  );
}

/** One thread, read-only, for audit. */
function ThreadView({ id }: { id: string }) {
  const tz = useMe().school.timezone;
  const threads = $api.useQuery("get", "/threads");
  const msgs = $api.useQuery("get", "/threads/{id}/messages", { params: { path: { id }, query: { limit: 200 } } });
  const t = threads.data?.items?.find((x) => x.id === id);
  if (!t || !msgs.data) return <p className="text-mute">Loading…</p>;
  const name = (sender: string) => (sender === t.teacher?.id ? t.teacher?.full_name : t.guardian?.full_name) ?? "Unknown";
  return (
    <MessageThread
      t={{
        student: t.student?.full_name ?? "",
        section: t.student?.class_section?.name ?? "",
        teacher: t.teacher?.full_name ?? "",
        guardian: t.guardian?.full_name ?? "",
        msgs: (msgs.data.items ?? []).map((m) => ({ from: name(m.sender_id!), text: m.body!, time: fmtStamp(m.created_at!, tz) })),
      }}
    />
  );
}

export function MessagesAudit() {
  const q = $api.useQuery("get", "/threads");
  const items = q.data?.items ?? [];
  const [sel, setSel] = useState("");
  const cur = sel || items[0]?.id || "";
  return (
    <Screen eyebrow="Oversight" title="Messages audit" queries={[q]} empty={items.length === 0} emptyText="No message threads have been started.">
      {() => (
        <div className="grid gap-5 lg:grid-cols-[2fr_3fr]">
          <Card plain flush>
            <ul className="divide-y divide-rule">
              {items.map((t) => (
                <li key={t.id}>
                  <button onClick={() => setSel(t.id!)} className={`w-full px-4 py-3 text-left hover:bg-accent-soft ${cur === t.id ? "bg-accent-soft" : ""}`}>
                    <div className="font-semibold">{t.student?.full_name} <span className="mono text-xs text-mute">{t.student?.class_section?.name}</span></div>
                    <div className="text-xs text-mute">{t.guardian?.full_name} and {t.teacher?.full_name}</div>
                    <div className="truncate text-sm text-soft">{t.last_message?.body}</div>
                  </button>
                </li>
              ))}
            </ul>
          </Card>
          <Card title="Read-only thread" eyebrow="Audited">{cur && <ThreadView id={cur} />}</Card>
        </div>
      )}
    </Screen>
  );
}

export function Conferences() {
  const { toast } = useApp();
  const me = useMe();
  const qc = useQueryClient();
  const tz = me.school.timezone;
  const teachers = $api.useQuery("get", "/people", { params: { query: { role: "teacher", limit: 200 } } });
  const list = teachers.data?.items ?? [];
  const [teacher, setTeacher] = useState("");
  const tid = teacher || list[0]?.id || "";
  const [form, setForm] = useState({ date: "", from: "09:00", to: "12:00", minutes: "15" });
  const slots = $api.useQuery("get", "/conference_slots", { params: { query: { teacher_id: tid } } }, { enabled: !!tid });
  const create = $api.useMutation("post", "/conference_slots", {
    onSuccess: (r) => {
      toast(`${r.items?.length ?? 0} slots created`);
      void qc.invalidateQueries({ queryKey: ["get", "/conference_slots"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });
  const all = slots.data?.items ?? [];
  const byDay = new Map<string, typeof all>();
  for (const s of all) {
    const day = s.starts_at!.slice(0, 10);
    byDay.set(day, [...(byDay.get(day) ?? []), s]);
  }
  const valid = form.date && form.from < form.to && Number(form.minutes) >= 5 && tid;
  const hhmm = (iso: string) => new Intl.DateTimeFormat("en-GB", { hour: "2-digit", minute: "2-digit", timeZone: tz }).format(new Date(iso));
  return (
    <Screen eyebrow="Schedule" title="Conference slots" queries={[teachers]}>
      {({ locked }) => (
        <div className="grid gap-5 lg:grid-cols-[2fr_3fr]">
          <Card title="Create slots">
            <div className="space-y-3">
              <Field label="Teacher">
                <select className={inputCls} value={tid} onChange={(e) => setTeacher(e.target.value)}>
                  {list.map((s) => (
                    <option key={s.id} value={s.id}>{s.full_name}</option>
                  ))}
                </select>
              </Field>
              <Field label="Date"><input type="date" className={inputCls} value={form.date} onChange={(e) => setForm({ ...form, date: e.target.value })} /></Field>
              <div className="grid grid-cols-3 gap-3">
                <Field label="From"><input type="time" className={inputCls} value={form.from} onChange={(e) => setForm({ ...form, from: e.target.value })} /></Field>
                <Field label="To"><input type="time" className={inputCls} value={form.to} onChange={(e) => setForm({ ...form, to: e.target.value })} /></Field>
                <Field label="Minutes"><input className={inputCls} inputMode="numeric" value={form.minutes} onChange={(e) => setForm({ ...form, minutes: e.target.value })} /></Field>
              </div>
              <Btn
                disabled={locked || !valid || create.isPending}
                onClick={() => create.mutate({ body: { teacher_id: tid, starts_at: zonedToIso(form.date, form.from, tz), ends_at: zonedToIso(form.date, form.to, tz), slot_minutes: Number(form.minutes) } })}
              >
                Create slots
              </Btn>
            </div>
          </Card>
          <div className="space-y-4">
            {slots.isPending && <p className="text-mute">Loading…</p>}
            {!slots.isPending && byDay.size === 0 && <p className="rounded-reg border border-dashed border-rule p-8 text-center text-mute">No slots have been opened for this teacher.</p>}
            {[...byDay.entries()].map(([day, daySlots]) => (
              <Card key={day} title={fmtDayWeekday(day)} eyebrow={`${daySlots.filter((s) => s.booked).length} of ${daySlots.length} booked`}>
                <div className="grid grid-cols-3 gap-2 sm:grid-cols-4">
                  {daySlots.map((s) => (
                    <div key={s.id} className={`rounded-reg border p-2 text-center text-xs ${s.booked ? "border-accent bg-accent-soft" : "border-rule"}`}>
                      <div className="mono font-semibold">{hhmm(s.starts_at!)}</div>
                      <div className="truncate text-mute">{s.student?.full_name ?? (s.booked ? "Booked" : "Open")}</div>
                    </div>
                  ))}
                </div>
              </Card>
            ))}
          </div>
        </div>
      )}
    </Screen>
  );
}
