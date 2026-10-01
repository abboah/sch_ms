import { useEffect, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { $api, api } from "../api/client";
import { errorMessage } from "../api/errors";
import { signOut, useMe } from "../auth/auth";
import { fmtStamp } from "../lib/format";
import { Banner, Btn, Card, Field, Screen, Tag, go, inputCls, useApp } from "../ui";

const KIND: Record<string, { label: string; tone: "mute" | "forest" | "brass" | "alert" | "accent" }> = {
  "attendance.marked": { label: "Attendance", tone: "alert" },
  "payment.succeeded": { label: "Payment", tone: "forest" },
  "fees.due_soon": { label: "Fees", tone: "brass" },
  "homework.posted": { label: "Homework", tone: "accent" },
  "announcement.published": { label: "Notice", tone: "accent" },
  "message.sent": { label: "Message", tone: "mute" },
};

export function Notifications() {
  const me = useMe();
  const qc = useQueryClient();
  const q = $api.useQuery("get", "/notifications", { params: { query: { limit: 50 } } });
  const mark = $api.useMutation("post", "/notifications/read", { onSuccess: () => void qc.invalidateQueries({ queryKey: ["get", "/notifications"] }) });
  const items = q.data?.items ?? [];
  return (
    <Screen eyebrow="Inbox" title="Notifications" narrow queries={[q]} empty={items.length === 0} emptyText="You are all caught up.">
      {() => (
        <Card flush actions={q.data && q.data.unread_count > 0 ? <Btn variant="ghost" onClick={() => mark.mutate({ body: {} })}>Mark all read</Btn> : undefined}>
          <ul className="divide-y divide-rule">
            {items.map((n) => {
              const k = KIND[n.kind] ?? { label: n.kind, tone: "mute" as const };
              return (
                <li key={n.id} className="flex items-start gap-3 px-4 py-3">
                  <span className={`mt-2 h-2 w-2 shrink-0 rounded-full ${n.read_at ? "bg-transparent" : "bg-alert"}`} aria-label={n.read_at ? "Read" : "Unread"} />
                  <div className="min-w-0 flex-1">
                    <Tag tone={k.tone}>{k.label}</Tag>
                    <div className="mt-1 font-semibold">{n.title}</div>
                    <p className="text-soft">{n.body}</p>
                    <div className="mono text-xs text-mute">{fmtStamp(n.created_at, me.school.timezone)}</div>
                  </div>
                  {!n.read_at && <button className="text-sm font-semibold text-accent" onClick={() => mark.mutate({ body: { ids: [n.id] } })}>Mark read</button>}
                </li>
              );
            })}
          </ul>
        </Card>
      )}
    </Screen>
  );
}

export function Settings() {
  const me = useMe();
  const { theme, setTheme, toast } = useApp();
  const qc = useQueryClient();
  const [phone, setPhone] = useState(me.contact?.phone ?? "");
  const [email, setEmail] = useState(me.contact?.email ?? "");
  const [saving, setSaving] = useState(false);
  const [problem, setProblem] = useState<string | null>(null);
  const prefs = $api.useQuery("get", "/me/notification_prefs");
  const setPrefs = $api.useMutation("put", "/me/notification_prefs", {
    onSuccess: (p) => qc.setQueryData(["get", "/me/notification_prefs", {}], p),
    onError: (e) => toast(errorMessage(e)),
  });

  useEffect(() => {
    setPhone(me.contact?.phone ?? "");
    setEmail(me.contact?.email ?? "");
  }, [me.contact?.phone, me.contact?.email]);

  const saveContact = async () => {
    setSaving(true);
    setProblem(null);
    try {
      const { data, error } = await api.PUT("/me/contact", { body: { phone: phone.trim() || null, email: email.trim() || null } });
      if (error) setProblem(errorMessage(error));
      else {
        setPhone(data.phone ?? "");
        setEmail(data.email ?? "");
        toast("Details saved");
      }
    } catch (e) {
      setProblem(errorMessage(e));
    }
    setSaving(false);
  };

  const channels = [
    ["push", "Push (the Homeroom app)"],
    ["email", "Email (receipts)"],
    ["sms", "SMS (when you have no app)"],
  ] as const;

  return (
    <Screen eyebrow={me.role === "guardian" ? "Guardian" : me.role} title="Profile and settings" narrow>
      {() => (
        <div className="space-y-5">
          <Card title="Contact details">
            {problem && <Banner tone="alert">{problem}</Banner>}
            <div className="grid gap-4 sm:grid-cols-2">
              <Field label="Name"><input className={inputCls} value={me.full_name} readOnly /></Field>
              <Field label="Mobile"><input className={inputCls + " mono"} inputMode="tel" value={phone} onChange={(e) => setPhone(e.target.value)} /></Field>
              <Field label="Email" className="sm:col-span-2"><input className={inputCls} type="email" value={email} onChange={(e) => setEmail(e.target.value)} /></Field>
            </div>
            <Btn className="mt-4" disabled={saving} onClick={() => void saveContact()}>{saving ? "Saving…" : "Save"}</Btn>
          </Card>
          <Card title="Notification channels">
            {prefs.data &&
              channels.map(([key, label]) => (
                <label key={key} className="flex items-center justify-between border-b border-rule/70 py-2.5 last:border-0">
                  <span>{label}</span>
                  <input type="checkbox" checked={prefs.data![key]} disabled={setPrefs.isPending} onChange={(e) => setPrefs.mutate({ body: { ...prefs.data!, [key]: e.target.checked } })} className="h-5 w-5 accent-[var(--accent)]" />
                </label>
              ))}
            {prefs.isPending && <p className="text-mute">Loading…</p>}
          </Card>
          <Card title="Theme">
            <div className="flex gap-2">
              {(["light", "dark"] as const).map((t) => (
                <Btn key={t} variant={theme === t ? "primary" : "ghost"} onClick={() => setTheme(t)} className="capitalize">{t}</Btn>
              ))}
            </div>
          </Card>
          <Btn variant="danger" onClick={() => void signOut().then(() => go("/signin"))}>Sign out</Btn>
        </div>
      )}
    </Screen>
  );
}

/**
 * Development stand-in for the payment provider's checkout page (see backend /dev/sandbox/complete).
 * In production the gateway's own hosted page is used and this route does nothing.
 */
export function SandboxCheckout({ reference }: { reference: string }) {
  const { toast } = useApp();
  const [busy, setBusy] = useState(false);
  const done = async (outcome: "succeeded" | "failed") => {
    setBusy(true);
    try {
      const { error } = await api.POST("/dev/sandbox/complete", { body: { reference, outcome } });
      if (error) toast(errorMessage(error));
      else {
        toast(outcome === "succeeded" ? "Payment approved" : "Payment declined");
        go("/parent/fees");
      }
    } catch (e) {
      toast(errorMessage(e));
    }
    setBusy(false);
  };
  return (
    <Screen eyebrow="Sandbox" title="Payment provider checkout" narrow>
      {() =>
        import.meta.env.DEV ? (
          <Card>
            <p className="text-soft">This stands in for your bank's checkout page. No real money moves.</p>
            <p className="mono my-3 text-xs text-mute">{reference}</p>
            <div className="flex gap-2">
              <Btn disabled={busy} onClick={() => void done("succeeded")}>Approve payment</Btn>
              <Btn variant="ghost" disabled={busy} onClick={() => void done("failed")}>Decline</Btn>
            </div>
          </Card>
        ) : (
          <p className="text-mute">This page only exists in development.</p>
        )
      }
    </Screen>
  );
}
