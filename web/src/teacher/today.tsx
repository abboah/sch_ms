import { useEffect, useState } from "react";
import { $api } from "../api/client";
import { errorMessage } from "../api/errors";
import { useMe } from "../auth/auth";
import { fmtLong, fromLetter, fmtTime, todayIn, type Status } from "../lib/format";
import { outbox } from "../offline/queue";
import { AttToggle, Avatar, Banner, Btn, Card, Screen, StatTile, Tag, go, useApp } from "../ui";
import { greeting, useToday } from "./shared";

export function Today() {
  const me = useMe();
  const q = useToday();
  const periods = q.data?.periods ?? [];
  const unmarked = periods.filter((p) => p.register === "unmarked").length;
  const partial = periods.filter((p) => p.register === "partial").length;
  const first = me.full_name.split(" ")[0];
  return (
    <Screen
      eyebrow={q.data ? fmtLong(q.data.date) : "Today"}
      title={`${greeting(me.school.timezone)}, ${first}`}
      narrow
      queries={[q]}
      empty={periods.length === 0}
      emptyText="You have no periods today."
    >
      {() => (
        <div className="space-y-5">
          <div className="grid gap-4 sm:grid-cols-3">
            <StatTile label="Periods today" value={String(periods.length)} sub={[...new Set(periods.map((p) => p.period.subject))].join(", ")} />
            <StatTile label="Unmarked registers" value={String(unmarked)} sub={unmarked ? "Needs attention" : "All started"} tone={unmarked ? "alert" : undefined} />
            <StatTile label="Partly marked" value={String(partial)} sub={partial ? "Finish these" : "None"} />
          </div>
          <Card title="My periods" flush>
            <ul className="divide-y divide-rule">
              {periods.map((p) => (
                <li key={p.period.id} className="flex flex-wrap items-center gap-3 px-4 py-3">
                  <div className="mono w-32 text-sm text-mute">{p.period.starts_at} to {p.period.ends_at}</div>
                  <div className="min-w-0 flex-1">
                    <div className="font-semibold">
                      {p.period.subject} <span className="mono text-sm text-mute">{p.class_section.name}</span>
                    </div>
                    <div className="text-xs text-mute">{p.marked} of {p.enrolled} marked</div>
                  </div>
                  {p.register === "complete" ? <Tag tone="forest">Marked</Tag> : p.register === "partial" ? <Tag tone="brass">Partly marked</Tag> : <Tag tone="alert">Unmarked</Tag>}
                  <Btn variant={p.register === "complete" ? "ghost" : "primary"} onClick={() => go(`/teacher/attendance/${p.class_section.id}/${p.period.id}/${q.data!.date}`)}>
                    {p.register === "complete" ? "Review" : "Take attendance"}
                  </Btn>
                </li>
              ))}
            </ul>
          </Card>
        </div>
      )}
    </Screen>
  );
}

/** /teacher/attendance with no section: jump to the register most in need of attention today. */
export function AttendanceIndex() {
  const q = useToday();
  const periods = q.data?.periods ?? [];
  const target = periods.find((p) => p.register !== "complete") ?? periods[0];
  useEffect(() => {
    if (target && q.data) go(`/teacher/attendance/${target.class_section.id}/${target.period.id}/${q.data.date}`);
  }, [target, q.data]);
  return (
    <Screen title="Attendance" narrow queries={[q]} empty={periods.length === 0} emptyText="You have no periods today, so there is no register to take.">
      {() => <p className="text-mute">Opening your register…</p>}
    </Screen>
  );
}

export function Attendance({ sec, period, date }: { sec: string; period: string; date?: string }) {
  const me = useMe();
  const { toast } = useApp();
  const tz = me.school.timezone;
  const day = date ?? todayIn(tz);
  const today = useToday(day);
  const reg = $api.useQuery("get", "/class_sections/{id}/attendance", { params: { path: { id: sec }, query: { date: day, period_id: period } } });
  const info = today.data?.periods.find((p) => p.period.id === period);
  const entries = reg.data?.entries ?? [];

  const [marks, setMarks] = useState<Record<string, Status>>({}); // unsaved or queued edits
  const [note, setNote] = useState<{ tone: "forest" | "brass" | "alert"; text: string } | null>(null);
  const [saving, setSaving] = useState(false);

  const current = (studentId: string, server: string | null): Status | undefined => {
    const m = marks[studentId];
    if (m) return m;
    return server ? ({ present: "P", late: "L", absent: "A", excused: "E" } as const)[server as "present"] : undefined;
  };
  const marked = entries.filter((e) => current(e.student.id, e.status)).length;
  const dirty = Object.keys(marks).length;

  const save = async () => {
    setSaving(true);
    setNote(null);
    const body = {
      date: day,
      period_id: period,
      entries: Object.entries(marks).map(([student_id, s]) => ({ student_id, status: fromLetter(s), marked_at: new Date().toISOString() })),
    };
    const result = await outbox.submit({ method: "PUT", path: `/class_sections/${sec}/attendance`, body, label: `Register for ${info?.class_section.name ?? "your class"}, ${info?.period.subject ?? ""}` });
    setSaving(false);
    const at = fmtTime(new Date().toISOString(), tz);
    if (result.status === "queued") {
      setNote({ tone: "brass", text: `Saved on this device at ${at}. It will sync when you reconnect.` });
      toast("Queued for sync");
    } else if (result.status === "rejected") {
      setNote({ tone: "alert", text: result.problem?.detail ?? result.problem?.title ?? "The register could not be saved." });
    } else {
      const res = result.body as { applied: number; rejected: number; results: { student_id: string; outcome: string; message?: string }[] } | null;
      const refused = (res?.results ?? []).filter((r) => r.outcome === "rejected");
      const names = (id: string) => entries.find((e) => e.student.id === id)?.student.full_name ?? "A student";
      setNote(
        refused.length
          ? { tone: "alert", text: `Saved at ${at}, except: ${refused.map((r) => `${names(r.student_id)} (${r.message ?? "not accepted"})`).join("; ")}.` }
          : { tone: "forest", text: `Register saved at ${at}. ${marked} of ${entries.length} marked.` },
      );
      setMarks({});
      toast("Register saved");
      void reg.refetch();
      void today.refetch();
    }
  };

  return (
    <Screen
      withOffline
      eyebrow={info ? `${info.period.starts_at} to ${info.period.ends_at}` : "Register"}
      title={info ? `${info.period.subject}, ${info.class_section.name}` : "Attendance"}
      narrow
      queries={[reg]}
      locked={reg.data?.term_closed}
      empty={entries.length === 0}
      emptyText="No students are enrolled in this section."
    >
      {({ locked }) => (
        <>
          {note && <Banner tone={note.tone}>{note.text}</Banner>}
          {reg.isError && <Banner tone="alert">{errorMessage(reg.error)}</Banner>}
          <Card>
            <div className="mb-3 flex flex-wrap items-center gap-3">
              <div className="mono text-sm"><b>{marked}</b> of {entries.length} marked</div>
              <div className="h-2 min-w-24 flex-1 overflow-hidden rounded-full border border-rule">
                <i className="block h-full bg-accent transition-all" style={{ width: (entries.length ? (marked / entries.length) * 100 : 0) + "%" }} />
              </div>
              <Btn
                variant="ghost"
                disabled={locked}
                onClick={() => setMarks((m) => ({ ...m, ...Object.fromEntries(entries.filter((e) => !current(e.student.id, e.status)).map((e) => [e.student.id, "P" as Status])) }))}
              >
                Mark the rest present
              </Btn>
            </div>
            <ul className="divide-y divide-rule">
              {entries.map((e, i) => (
                <li key={e.student.id} className="flex items-center gap-3 py-2">
                  <span className="mono w-5 text-xs text-mute">{i + 1}</span>
                  <Avatar name={e.student.full_name} />
                  <span className="min-w-0 flex-1 truncate font-semibold">{e.student.full_name}</span>
                  <AttToggle
                    value={current(e.student.id, e.status)}
                    disabled={locked}
                    onChange={(v) => {
                      setMarks({ ...marks, [e.student.id]: v });
                      setNote(null);
                    }}
                  />
                </li>
              ))}
            </ul>
            <div className="mt-4 flex flex-wrap items-center gap-3 border-t border-rule pt-4">
              <Btn disabled={locked || saving || dirty === 0} onClick={() => void save()}>{saving ? "Saving…" : "Save register"}</Btn>
              <span className="text-sm text-mute">
                {dirty === 0 ? (marked === entries.length ? "Everyone is marked." : "Mark students, then save.") : `${dirty} change${dirty === 1 ? "" : "s"} to save${marked < entries.length ? `, ${entries.length - marked} not marked yet` : ""}.`}
              </span>
            </div>
          </Card>
        </>
      )}
    </Screen>
  );
}
