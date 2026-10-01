import { useEffect, useRef, useState } from "react";
import { $api, api } from "../api/client";
import { errorMessage } from "../api/errors";
import { useMe } from "../auth/auth";
import { fmtDay, fmtStamp, money } from "../lib/format";
import { Btn, Card, Screen, Tag, go, inputCls, invTone, useApp } from "../ui";
import { ChildSwitcher, NoChildren, useChild } from "./shared";

type Method = "card" | "mtn_momo" | "telecel_cash";
const METHODS: { id: Method; label: string }[] = [
  { id: "card", label: "Card" },
  { id: "mtn_momo", label: "MTN MoMo" },
  { id: "telecel_cash", label: "Telecel Cash" },
];
const label = (i: { status: string; overdue: boolean }) => (i.overdue ? "Overdue" : i.status.charAt(0).toUpperCase() + i.status.slice(1));

export function Fees() {
  const me = useMe();
  const c = useChild();
  const q = $api.useQuery("get", "/students/{id}/invoices", { params: { path: { id: c?.id ?? "" } } }, { enabled: !!c, refetchInterval: 20_000 });
  const items = q.data?.items ?? [];
  const pending = items.flatMap((i) => i.payments.filter((p) => p.status === "pending").map((p) => ({ ...p, invoice: i })));
  const receipts = items
    .flatMap((i) => i.payments.filter((p) => p.status === "succeeded").map((p) => ({ ...p, invoice: i })))
    .sort((a, b) => (b.paid_at ?? "").localeCompare(a.paid_at ?? ""));
  return (
    <Screen eyebrow={me.school.term?.name} title="Fees" narrow queries={c ? [q] : []} empty={!!c && items.length === 0} emptyText="No invoices have been issued.">
      {({ locked }) =>
        !c ? <NoChildren /> : (
          <>
            <ChildSwitcher />
            <div className="space-y-5">
              {items.map((inv) => {
                const owed = Number(inv.outstanding);
                return (
                  <Card key={inv.id} title={inv.description} eyebrow={`Due ${fmtDay(inv.due_date)}`}>
                    <div className="flex flex-wrap items-center gap-x-6 gap-y-3">
                      <div><div className="eyebrow">Total</div><div className="mono">{money(inv.amount_due)}</div></div>
                      <div><div className="eyebrow">Paid</div><div className="mono">{money(inv.amount_paid)}</div></div>
                      <div><div className="eyebrow">Balance</div><div className={`mono text-lg font-semibold ${owed > 0 ? "text-alert" : "text-forest"}`}>{money(inv.outstanding)}</div></div>
                      <Tag tone={invTone(label(inv))}>{label(inv)}</Tag>
                      <Btn className="ml-auto" disabled={owed <= 0 || locked} onClick={() => go("/parent/fees/pay/" + inv.id)}>{owed > 0 ? "Pay" : "Paid"}</Btn>
                    </div>
                  </Card>
                );
              })}
              {pending.map((p) => (
                <p key={p.id} className="rounded-reg border border-brass bg-brass-soft px-3 py-2 text-sm">
                  A payment of {money(p.amount)} for {p.invoice.description} is pending confirmation. It will appear in your receipts once the provider confirms it.
                </p>
              ))}
              <Card title="Receipt history" flush>
                {receipts.length === 0 ? <p className="p-4 text-mute">No payments yet.</p> : (
                  <ul className="divide-y divide-rule">
                    {receipts.map((p) => (
                      <li key={p.id} className="flex flex-wrap items-center justify-between gap-3 px-4 py-2.5 text-sm">
                        <span className="mono text-mute">{p.paid_at ? fmtStamp(p.paid_at, me.school.timezone) : ""}</span>
                        <span className="mono">{p.provider_ref.slice(0, 18)}</span>
                        <span className="mono ml-auto">{money(p.amount)}</span>
                      </li>
                    ))}
                  </ul>
                )}
              </Card>
            </div>
          </>
        )
      }
    </Screen>
  );
}

type Step = "form" | "processing" | "success" | "failure" | "pending";
const POLL_MS = 3000;
const GIVE_UP_MS = 90_000;

export function Pay({ id }: { id: string }) {
  const me = useMe();
  const c = useChild();
  const { toast } = useApp();
  const q = $api.useQuery("get", "/students/{id}/invoices", { params: { path: { id: c?.id ?? "" } } }, { enabled: !!c });
  const inv = q.data?.items.find((i) => i.id === id);
  const owed = Number(inv?.outstanding ?? 0);

  const [amt, setAmt] = useState("");
  const [method, setMethod] = useState<Method>("card");
  const [phone, setPhone] = useState(me.contact?.phone ?? "");
  const [step, setStep] = useState<Step>("form");
  const [reason, setReason] = useState<string | null>(null);
  const [prompt, setPrompt] = useState<string | null>(null);
  const [payment, setPayment] = useState<{ id: string; ref: string } | null>(null);
  const started = useRef(0);
  const key = useRef<string | null>(null);

  useEffect(() => {
    if (inv && amt === "") setAmt(inv.outstanding);
  }, [inv, amt]);

  const n = Number(amt);
  const valid = /^\d+(\.\d{1,2})?$/.test(amt) && n > 0 && n <= owed && (method === "card" || phone.trim().length >= 9);

  // After a mobile-money prompt, ask the server whether the provider has confirmed, every few seconds.
  const poll = $api.useQuery("get", "/payments/{id}", { params: { path: { id: payment?.id ?? "" } } }, { enabled: step === "processing" && !!payment, refetchInterval: POLL_MS, refetchIntervalInBackground: true /* the user may be approving on their phone */, retry: true });
  useEffect(() => {
    const s = poll.data?.status;
    if (step !== "processing" || !s) return;
    if (s === "succeeded") setStep("success");
    else if (s === "failed") { setReason("The provider did not confirm the payment. You have not been charged."); setStep("failure"); }
    else if (Date.now() - started.current > GIVE_UP_MS) setStep("pending");
  }, [poll.data, poll.dataUpdatedAt, step]);

  const run = async () => {
    setStep("processing");
    setReason(null);
    started.current = Date.now();
    key.current ??= globalThis.crypto?.randomUUID?.() ?? `${Date.now()}-${Math.random()}`;
    try {
      const { data, error } = await api.POST("/invoices/{id}/pay", {
        params: { path: { id }, header: { "Idempotency-Key": key.current } },
        body: { amount: Number(amt).toFixed(2), method, ...(method !== "card" ? { phone: phone.trim() } : {}) },
      });
      if (error || !data) {
        key.current = null;
        setReason(errorMessage(error));
        setStep("failure");
        return;
      }
      setPayment({ id: data.payment.id, ref: data.payment.provider_ref });
      if (data.next.type === "redirect" && data.next.redirect_url) {
        window.location.assign(data.next.redirect_url); // the provider's hosted checkout
        return;
      }
      setPrompt(data.next.message ?? "Approve the request on your phone.");
    } catch (e) {
      // The connection dropped. Keep the key: if the request did reach the server, a retry replays it instead of charging twice.
      setReason(errorMessage(e));
      setStep("failure");
    }
  };

  const simulate = async (outcome: "succeeded" | "failed") => {
    if (!payment) return;
    const { error } = await api.POST("/dev/sandbox/complete", { body: { reference: payment.ref, outcome } });
    if (error) toast(errorMessage(error));
  };

  return (
    <Screen eyebrow={inv && c ? `${c.full_name}, ${inv.description}` : "Payment"} title="Make a payment" narrow queries={c ? [q] : []}>
      {() => (
        <Card>
          {!inv ? <p className="text-mute">That invoice was not found.</p> : step === "form" ? (
            <div className="space-y-5">
              <div>
                <label className="eyebrow mb-1 block" htmlFor="amt">Amount (GH¢)</label>
                <input id="amt" inputMode="decimal" value={amt} onChange={(e) => setAmt(e.target.value)} className={inputCls + " mono text-lg"} />
                <p className={`mt-1 text-sm ${valid || !amt ? "text-mute" : "text-alert"}`}>{n > 0 && n <= owed ? `Balance is ${money(owed)}. You can pay part of it.` : `Enter an amount up to ${money(owed)}.`}</p>
              </div>
              <fieldset>
                <legend className="eyebrow mb-1">Method</legend>
                <div className="grid gap-2 sm:grid-cols-3">
                  {METHODS.map((m) => (
                    <label key={m.id} className={`flex min-h-12 cursor-pointer items-center gap-2 rounded-reg border px-3 ${method === m.id ? "border-accent bg-accent-soft" : "border-rule"}`}>
                      <input type="radio" name="m" checked={method === m.id} onChange={() => setMethod(m.id)} className="accent-[var(--accent)]" />{m.label}
                    </label>
                  ))}
                </div>
              </fieldset>
              {method !== "card" && (
                <div>
                  <label className="eyebrow mb-1 block" htmlFor="ph">Mobile money number</label>
                  <input id="ph" inputMode="tel" value={phone} onChange={(e) => setPhone(e.target.value)} className={inputCls + " mono"} />
                </div>
              )}
              <Btn disabled={!valid} onClick={() => void run()} className="w-full sm:w-auto">Pay {valid ? money(n) : ""}</Btn>
            </div>
          ) : step === "processing" ? (
            <div role="status" className="py-8 text-center">
              <div className="mx-auto mb-4 h-8 w-8 animate-spin rounded-full border-2 border-rule border-t-accent" />
              <div className="font-semibold">Processing {money(n)}</div>
              <p className="text-sm text-mute">{prompt ?? (method === "card" ? "Opening your bank's checkout." : "Contacting the provider.")}</p>
              {import.meta.env.DEV && payment && prompt && (
                <div className="mt-4 flex justify-center gap-2">
                  <Btn variant="ghost" onClick={() => void simulate("succeeded")}>Simulate approval (sandbox)</Btn>
                  <Btn variant="ghost" onClick={() => void simulate("failed")}>Simulate decline</Btn>
                </div>
              )}
            </div>
          ) : step === "success" ? (
            <div className="py-4">
              <Tag tone="forest">Paid</Tag>
              <h2 className="mt-2 text-2xl">Payment received</h2>
              <dl className="mono my-4 space-y-1 text-sm"><div>Reference {payment?.ref.slice(0, 18)}</div><div>{money(n)} via {METHODS.find((m) => m.id === method)?.label}</div><div>{c?.full_name}, {inv.description}</div></dl>
              <Btn onClick={() => go("/parent/fees")}>Back to fees</Btn>
            </div>
          ) : step === "failure" ? (
            <div role="alert" className="py-4">
              <Tag tone="alert">Failed</Tag>
              <h2 className="mt-2 text-2xl">Payment did not go through</h2>
              <p className="my-3 text-soft">{reason}</p>
              <div className="flex gap-2"><Btn onClick={() => void run()}>Retry</Btn><Btn variant="ghost" onClick={() => { key.current = null; setStep("form"); }}>Change method</Btn></div>
            </div>
          ) : (
            <div className="py-4">
              <Tag tone="brass">Pending confirmation</Tag>
              <h2 className="mt-2 text-2xl">Waiting for the provider</h2>
              <p className="my-3 text-soft">We have not yet heard back about your {money(n)} payment. This usually takes a few minutes. Your balance updates as soon as it is confirmed, and you can close this page.</p>
              <Btn onClick={() => go("/parent/fees")}>Back to fees</Btn>
            </div>
          )}
        </Card>
      )}
    </Screen>
  );
}
