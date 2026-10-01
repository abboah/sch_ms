import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { $api } from "../api/client";
import { errorMessage } from "../api/errors";
import { useMe } from "../auth/auth";
import { fmtDayWeekday, fmtStamp } from "../lib/format";
import { Conversations } from "../pages/messages";
import { Banner, Btn, Card, Screen, Tag, useApp } from "../ui";
import { ChildSwitcher, NoChildren, useChild } from "./shared";

/** The teachers of the child's class, as people the parent can write to. */
function useChildTeachers() {
  const c = useChild();
  const sectionId = c?.class_section?.id ?? "";
  const q = $api.useQuery("get", "/class_sections/{id}", { params: { path: { id: sectionId } } }, { enabled: !!sectionId });
  const seen = new Map<string, { id: string; name: string; subjects: string[] }>();
  for (const t of q.data?.teachers ?? []) {
    const cur = seen.get(t.person.id) ?? { id: t.person.id, name: t.person.full_name, subjects: [] };
    if (t.subject !== "Homeroom") cur.subjects.push(t.subject);
    else cur.subjects.unshift("Homeroom");
    seen.set(t.person.id, cur);
  }
  return { query: q, teachers: [...seen.values()] };
}

function MessageATeacher() {
  const { toast } = useApp();
  const qc = useQueryClient();
  const c = useChild();
  const { teachers } = useChildTeachers();
  const open = $api.useMutation("post", "/threads", {
    onSuccess: () => {
      toast("Conversation opened");
      void qc.invalidateQueries({ queryKey: ["get", "/threads"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });
  if (!c || teachers.length === 0) return null;
  return (
    <Card title="Message a teacher" eyebrow={`About ${c.full_name}`}>
      <div className="flex flex-wrap gap-2">
        {teachers.map((t) => (
          <Btn key={t.id} variant="ghost" disabled={open.isPending} onClick={() => open.mutate({ body: { student_id: c.id, other_party_id: t.id } })}>
            {t.name} <span className="text-mute">({t.subjects.join(", ") || "Teacher"})</span>
          </Btn>
        ))}
      </div>
    </Card>
  );
}

export function Messages() {
  const c = useChild();
  if (!c) return <Screen title="Messages" narrow>{() => <NoChildren />}</Screen>;
  return (
    <div>
      <div className="mx-auto max-w-[880px]"><ChildSwitcher /></div>
      <Conversations key={c.id} studentId={c.id} compose={<MessageATeacher />} emptyText={`No conversations about ${c.full_name} yet.`} />
    </div>
  );
}

export function Announcements() {
  const me = useMe();
  const qc = useQueryClient();
  const { toast } = useApp();
  const kids = me.children ?? [];
  const q = $api.useQuery("get", "/announcements", { params: { query: { limit: 30 } } });
  const items = q.data?.items ?? [];
  const reply = $api.useMutation("put", "/announcements/{id}/responses", {
    onSuccess: () => {
      toast("Response sent");
      void qc.invalidateQueries({ queryKey: ["get", "/announcements"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });
  return (
    <Screen eyebrow={me.school.name} title="Announcements" narrow queries={[q]} empty={items.length === 0} emptyText="No announcements.">
      {({ locked }) => (
        <div className="space-y-4">
          {items.map((a) => (
            <Card key={a.id} title={a.title} eyebrow={a.published_at ? fmtStamp(a.published_at, me.school.timezone) : undefined}>
              <p className="text-soft">{a.body}</p>
              {a.requires_response && (
                <div className="mt-3 space-y-3 border-t border-rule pt-3">
                  {kids.map((k) => {
                    const mine = a.my_responses?.find((r) => r.student_id === k.id);
                    return (
                      <div key={k.id}>
                        <div className="eyebrow mb-2">Permission slip for {k.full_name}</div>
                        {mine ? (
                          <div className="flex items-center gap-3">
                            <Tag tone={mine.response === "yes" ? "forest" : "alert"}>{mine.response === "yes" ? "Permission given" : "Declined"}</Tag>
                            <button className="text-sm font-semibold text-accent" disabled={locked || reply.isPending} onClick={() => reply.mutate({ params: { path: { id: a.id } }, body: { student_id: k.id, response: mine.response === "yes" ? "no" : "yes" } })}>
                              Change to {mine.response === "yes" ? "decline" : "permission given"}
                            </button>
                          </div>
                        ) : (
                          <div className="flex gap-2">
                            <Btn disabled={locked || reply.isPending} onClick={() => reply.mutate({ params: { path: { id: a.id } }, body: { student_id: k.id, response: "yes" } })}>I give permission</Btn>
                            <Btn variant="ghost" disabled={locked || reply.isPending} onClick={() => reply.mutate({ params: { path: { id: a.id } }, body: { student_id: k.id, response: "no" } })}>Decline</Btn>
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              )}
            </Card>
          ))}
        </div>
      )}
    </Screen>
  );
}

export function Conference() {
  const me = useMe();
  const tz = me.school.timezone;
  const c = useChild();
  const qc = useQueryClient();
  const { toast } = useApp();
  const { query: secQ, teachers } = useChildTeachers();
  const slots = $api.useQuery("get", "/conference_slots");
  const [pick, setPick] = useState<string | null>(null);
  const teacherIds = new Set(teachers.map((t) => t.id));
  const mine = (slots.data?.items ?? []).filter((s) => teacherIds.has(s.teacher.id));
  const booked = mine.filter((s) => s.booked_by_me && s.student?.id === c?.id);

  const refresh = () => void qc.invalidateQueries({ queryKey: ["get", "/conference_slots"] });
  const book = $api.useMutation("put", "/conference_slots/{id}/booking", { onSuccess: () => { toast("Conference booked"); setPick(null); refresh(); }, onError: (e) => { toast(errorMessage(e)); refresh(); } });
  const release = $api.useMutation("delete", "/conference_slots/{id}/booking", { onSuccess: () => { toast("Booking cancelled"); refresh(); }, onError: (e) => toast(errorMessage(e)) });

  const hhmm = (iso: string) => new Intl.DateTimeFormat("en-GB", { hour: "2-digit", minute: "2-digit", timeZone: tz }).format(new Date(iso));
  const groups = new Map<string, typeof mine>();
  for (const s of mine) {
    const k = `${s.teacher.id}|${s.starts_at.slice(0, 10)}`;
    groups.set(k, [...(groups.get(k) ?? []), s]);
  }

  return (
    <Screen eyebrow={c ? `${c.full_name}'s teachers` : undefined} title="Book a conference" narrow queries={c ? [slots, secQ] : []} empty={!!c && mine.length === 0} emptyText="No conference slots have been opened for your child's teachers yet.">
      {({ locked }) =>
        !c ? <NoChildren /> : (
          <>
            <ChildSwitcher />
            {booked.map((b) => (
              <Banner key={b.id} tone="forest">
                You are booked with {b.teacher.full_name} at {hhmm(b.starts_at)}, {fmtDayWeekday(b.starts_at.slice(0, 10))}. Choose another slot to move it, or{" "}
                <button className="font-semibold underline" onClick={() => release.mutate({ params: { path: { id: b.id } } })}>cancel</button>.
              </Banner>
            ))}
            <div className="space-y-5">
              {[...groups.entries()].map(([key, list]) => (
                <Card key={key} title={fmtDayWeekday(list[0]!.starts_at.slice(0, 10))} eyebrow={`${list[0]!.teacher.full_name} · ${Math.round((new Date(list[0]!.ends_at).getTime() - new Date(list[0]!.starts_at).getTime()) / 60000)}-minute slots`}>
                  <div className="grid grid-cols-3 gap-2 sm:grid-cols-4">
                    {list.map((s) => {
                      const isMine = s.booked_by_me;
                      const taken = s.booked && !isMine;
                      return (
                        <button key={s.id} disabled={taken || isMine || locked} aria-pressed={pick === s.id} onClick={() => setPick(s.id)}
                          className={`mono min-h-12 rounded-reg border text-sm font-semibold disabled:cursor-not-allowed disabled:opacity-40 ${isMine ? "border-accent bg-accent-soft" : pick === s.id ? "border-accent ring-2 ring-accent" : "border-rule hover:bg-accent-soft"}`}>
                          {hhmm(s.starts_at)}
                          <span className="block font-sans text-[11px] font-normal text-mute">{isMine ? "Yours" : taken ? "Taken" : "Open"}</span>
                        </button>
                      );
                    })}
                  </div>
                </Card>
              ))}
              <Btn disabled={!pick || locked || book.isPending} onClick={() => pick && book.mutate({ params: { path: { id: pick } }, body: { student_id: c.id } })}>
                {pick ? `Book ${hhmm(mine.find((s) => s.id === pick)!.starts_at)}` : "Select a slot"}
              </Btn>
            </div>
          </>
        )
      }
    </Screen>
  );
}
