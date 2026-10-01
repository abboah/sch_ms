import { useEffect, useRef, useState, type ReactNode } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { $api } from "../api/client";
import { errorMessage } from "../api/errors";
import { useMe } from "../auth/auth";
import { fmtStamp } from "../lib/format";
import { Btn, Card, inputCls, MessageThread, Screen, useApp } from "../ui";

const newKey = () => (typeof crypto !== "undefined" && typeof crypto.randomUUID === "function" ? crypto.randomUUID() : `${Date.now()}-${Math.random()}`);

/**
 * Threads with one child at a time or all of a teacher's conversations: a list, the open thread, a reply box.
 * Used by both the teacher and parent portals. Polls lightly so new messages appear without a refresh;
 * opening a thread marks it read; a reply is retried with the same Idempotency-Key until it succeeds,
 * so a flaky connection can never send it twice.
 */
export function Conversations({ studentId, compose, eyebrow = "Communication", emptyText = "No conversations yet." }: { studentId?: string; compose?: ReactNode; eyebrow?: string; emptyText?: string }) {
  const me = useMe();
  const tz = me.school.timezone;
  const { toast } = useApp();
  const qc = useQueryClient();
  const threads = $api.useQuery("get", "/threads", { params: { query: studentId ? { student_id: studentId } : {} } }, { refetchInterval: 20_000 });
  const items = threads.data?.items ?? [];
  const [sel, setSel] = useState("");
  const cur = items.find((t) => t.id === sel) ?? items[0];
  const msgs = $api.useQuery("get", "/threads/{id}/messages", { params: { path: { id: cur?.id ?? "" }, query: { limit: 200 } } }, { enabled: !!cur, refetchInterval: 15_000 });
  const [reply, setReply] = useState("");
  const key = useRef<string | null>(null);

  const markRead = $api.useMutation("post", "/threads/{id}/read", { onSuccess: () => void qc.invalidateQueries({ queryKey: ["get", "/threads"] }) });
  const unread = cur?.unread ?? 0;
  const messageCount = msgs.data?.items.length ?? 0;
  useEffect(() => {
    if (cur && unread > 0 && messageCount > 0 && !markRead.isPending) markRead.mutate({ params: { path: { id: cur.id } } });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cur?.id, unread, messageCount]);

  const send = $api.useMutation("post", "/threads/{id}/messages", {
    onSuccess: () => {
      key.current = null;
      setReply("");
      void qc.invalidateQueries({ queryKey: ["get", "/threads"] });
      void qc.invalidateQueries({ queryKey: ["get", "/threads/{id}/messages"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });
  const submit = () => {
    if (!cur || !reply.trim()) return;
    key.current ??= newKey(); // the same key on a retry, so it cannot be delivered twice
    send.mutate({ params: { path: { id: cur.id }, header: { "Idempotency-Key": key.current } }, body: { body: reply.trim() } });
  };

  const nameOf = (senderId: string) => (senderId === cur?.teacher.id ? cur.teacher.full_name : cur?.guardian.full_name) ?? "Unknown";
  const thread = cur && {
    student: cur.student.full_name,
    section: cur.student.class_section?.name ?? "",
    teacher: cur.teacher.full_name,
    guardian: cur.guardian.full_name,
    msgs: (msgs.data?.items ?? []).map((m) => ({ from: nameOf(m.sender_id), text: m.body, time: fmtStamp(m.created_at, tz) })),
  };

  return (
    <Screen eyebrow={eyebrow} title="Messages" queries={[threads]} empty={items.length === 0 && !compose} emptyText={emptyText}>
      {() => (
        <div className="grid gap-5 lg:grid-cols-[2fr_3fr]">
          <div className="space-y-4">
            {compose}
            {items.length > 0 && (
              <Card plain flush>
                <ul className="divide-y divide-rule">
                  {items.map((x) => (
                    <li key={x.id}>
                      <button onClick={() => setSel(x.id)} className={`w-full px-4 py-3 text-left hover:bg-accent-soft ${cur?.id === x.id ? "bg-accent-soft" : ""}`}>
                        <div className="flex items-center justify-between gap-2">
                          <span className="font-semibold">{x.student.full_name} <span className="mono text-xs text-mute">{x.student.class_section?.name}</span></span>
                          {x.unread > 0 && <span className="mono rounded-full bg-alert px-1.5 text-[11px] font-semibold text-white">{x.unread}</span>}
                        </div>
                        <div className="text-xs text-mute">{me.role === "guardian" ? x.teacher.full_name : x.guardian.full_name}</div>
                        <div className="truncate text-sm text-soft">{x.last_message?.body ?? "No messages yet"}</div>
                      </button>
                    </li>
                  ))}
                </ul>
              </Card>
            )}
          </div>
          {cur && thread && (
            <Card>
              {msgs.isPending ? <p className="text-mute">Loading…</p> : <MessageThread t={thread} me={me.full_name} />}
              <div className="mt-4 flex gap-2">
                <input
                  aria-label="Reply"
                  className={inputCls}
                  value={reply}
                  onChange={(e) => setReply(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && submit()}
                  placeholder={`Reply about ${cur.student.full_name}`}
                />
                <Btn disabled={!reply.trim() || send.isPending} onClick={submit}>{send.isPending ? "Sending…" : "Send"}</Btn>
              </div>
            </Card>
          )}
        </div>
      )}
    </Screen>
  );
}
