import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { $api } from "../api/client";
import { errorMessage } from "../api/errors";
import { useMe } from "../auth/auth";
import { fmtDay, fmtStamp, money } from "../lib/format";
import { allItems, cursorPaging } from "../lib/hooks";
import { Btn, Card, DataTable, Field, inputCls, invTone, Screen, Tag, go, useApp } from "../ui";
import { LoadMore, POSITIVE_MONEY, cap, invoiceLabel, useSections } from "./shared";

const METHOD: Record<string, string> = { card: "Card", mtn_momo: "MTN MoMo", telecel_cash: "Telecel Cash", manual: "Manual" };

function FeeItems() {
  const { toast } = useApp();
  const qc = useQueryClient();
  const items = $api.useQuery("get", "/fee_items");
  const [draft, setDraft] = useState({ name: "", amount: "" });
  const refresh = () => void qc.invalidateQueries({ queryKey: ["get", "/fee_items"] });
  const create = $api.useMutation("post", "/fee_items", {
    onSuccess: () => { toast("Fee item added"); setDraft({ name: "", amount: "" }); refresh(); },
    onError: (e) => toast(errorMessage(e)),
  });
  const toggle = $api.useMutation("patch", "/fee_items/{id}", {
    onSuccess: () => refresh(),
    onError: (e) => toast(errorMessage(e)),
  });
  const valid = draft.name.trim() && POSITIVE_MONEY.test(draft.amount);
  const active = (items.data?.items ?? []).filter((f) => f.active);
  const retired = (items.data?.items ?? []).filter((f) => !f.active);
  return (
    <Card title="Fee items" eyebrow="Reusable charges, for the dropdown below">
      {(active.length > 0 || retired.length > 0) && (
        <ul className="mb-4 divide-y divide-rule text-sm">
          {[...active, ...retired].map((f) => (
            <li key={f.id} className="flex items-center justify-between gap-3 py-2">
              <span className={f.active ? "" : "text-mute line-through"}>{f.name} <span className="mono text-mute">{money(f.default_amount)}</span></span>
              <Btn variant="ghost" disabled={toggle.isPending} onClick={() => toggle.mutate({ params: { path: { id: f.id } }, body: { active: !f.active } })}>
                {f.active ? "Retire" : "Restore"}
              </Btn>
            </li>
          ))}
        </ul>
      )}
      <div className="grid gap-4 sm:grid-cols-3">
        <Field label="Name"><input className={inputCls} value={draft.name} onChange={(e) => setDraft({ ...draft, name: e.target.value })} placeholder="Term 1 Tuition" /></Field>
        <Field label="Default amount (GH¢)"><input className={inputCls + " mono"} inputMode="decimal" value={draft.amount} onChange={(e) => setDraft({ ...draft, amount: e.target.value })} placeholder="1850.00" /></Field>
        <div className="flex items-end">
          <Btn disabled={!valid || create.isPending} onClick={() => create.mutate({ body: { name: draft.name.trim(), default_amount: draft.amount } })}>Add fee item</Btn>
        </div>
      </div>
    </Card>
  );
}

export function Fees() {
  const { toast } = useApp();
  const me = useMe();
  const qc = useQueryClient();
  const [status, setStatus] = useState("");
  const { sections } = useSections();
  const list = $api.useInfiniteQuery("get", "/invoices", { params: { query: { limit: 50, ...(status ? { status: status as "paid" } : {}) } } }, cursorPaging);
  const rows = allItems(list.data);
  const feeItems = $api.useQuery("get", "/fee_items").data?.items ?? [];
  const [bill, setBill] = useState({ section: "", description: "Tuition", amount: "", due: "", feeItem: "" });
  const create = $api.useMutation("post", "/invoices", {
    onSuccess: (r) => {
      toast(`${r.items?.length ?? 0} invoices generated`);
      void qc.invalidateQueries({ queryKey: ["get", "/invoices"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });
  const pickFeeItem = (feeItemId: string) => {
    const f = feeItems.find((x) => x.id === feeItemId);
    setBill({ ...bill, feeItem: feeItemId, ...(f ? { description: f.name, amount: f.default_amount } : {}) });
  };
  const valid = bill.section && bill.description && POSITIVE_MONEY.test(bill.amount) && bill.due && me.school.term;
  return (
    <Screen eyebrow="Finance" title="Fees and invoices" queries={[list]}>
      {({ locked }) => (
        <div className="space-y-5">
          <FeeItems />
          <Card title="Generate invoices" eyebrow="One invoice per enrolled student">
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-6">
              <Field label="Section">
                <select className={inputCls} value={bill.section} onChange={(e) => setBill({ ...bill, section: e.target.value })}>
                  <option value="">Choose</option>
                  {sections.map((s) => (
                    <option key={s.id} value={s.id}>{s.name}</option>
                  ))}
                </select>
              </Field>
              {feeItems.length > 0 && (
                <Field label="Fee item">
                  <select className={inputCls} value={bill.feeItem} onChange={(e) => pickFeeItem(e.target.value)}>
                    <option value="">Custom</option>
                    {feeItems.filter((f) => f.active).map((f) => (
                      <option key={f.id} value={f.id}>{f.name}</option>
                    ))}
                  </select>
                </Field>
              )}
              <Field label="For"><input className={inputCls} value={bill.description} onChange={(e) => setBill({ ...bill, description: e.target.value, feeItem: "" })} /></Field>
              <Field label="Amount (GH¢)"><input className={inputCls + " mono"} inputMode="decimal" value={bill.amount} onChange={(e) => setBill({ ...bill, amount: e.target.value })} placeholder="1850.00" /></Field>
              <Field label="Due"><input type="date" className={inputCls} value={bill.due} onChange={(e) => setBill({ ...bill, due: e.target.value })} /></Field>
              <div className="flex items-end">
                <Btn
                  disabled={locked || !valid || create.isPending}
                  onClick={() =>
                    create.mutate({
                      body: {
                        class_section_id: bill.section, term_id: me.school.term!.id, description: bill.description,
                        amount_due: bill.amount, due_date: bill.due, ...(bill.feeItem ? { fee_item_id: bill.feeItem } : {}),
                      },
                    })
                  }
                >
                  Generate
                </Btn>
              </div>
            </div>
          </Card>
          <Card
            title="Invoices"
            flush
            plain
            actions={
              <select aria-label="Status" value={status} onChange={(e) => setStatus(e.target.value)} className={inputCls + " w-auto"}>
                {[["", "All"], ["paid", "Paid"], ["partial", "Partial"], ["unpaid", "Unpaid"], ["overdue", "Overdue"]].map(([v, l]) => (
                  <option key={v} value={v}>{l}</option>
                ))}
              </select>
            }
          >
            {rows.length === 0 ? (
              <p className="p-6 text-center text-mute">No invoices match.</p>
            ) : (
              <DataTable
                onRow={(i) => go("/admin/students/" + i.student!.id)}
                cols={[
                  { key: "student", label: "Student", render: (i) => <b>{i.student!.full_name}</b> },
                  { key: "description", label: "For" },
                  { key: "due_date", label: "Due", mono: true, render: (i) => fmtDay(i.due_date) },
                  { key: "amount_due", label: "Total", mono: true, align: "right", render: (i) => money(i.amount_due) },
                  { key: "outstanding", label: "Balance", mono: true, align: "right", render: (i) => money(i.outstanding) },
                  { key: "status", label: "Status", render: (i) => <Tag tone={invTone(invoiceLabel(i))}>{invoiceLabel(i)}</Tag> },
                ]}
                rows={rows}
              />
            )}
            <LoadMore q={list} />
          </Card>
        </div>
      )}
    </Screen>
  );
}

export function Payments() {
  const { toast } = useApp();
  const me = useMe();
  const qc = useQueryClient();
  const [filter, setFilter] = useState("");
  const list = $api.useInfiniteQuery(
    "get",
    "/payments",
    { params: { query: { limit: 50, ...(filter === "stale" ? { stale_pending: true } : filter ? { status: filter as "pending" } : {}) } } },
    cursorPaging,
  );
  const rows = allItems(list.data);
  const owing = $api.useQuery("get", "/invoices", { params: { query: { status: "overdue", limit: 100 } } });
  const open = owing.data?.items ?? [];
  const [m, setM] = useState({ invoice: "", amount: "", ref: "" });
  const record = $api.useMutation("post", "/payments", {
    onSuccess: () => {
      toast("Payment recorded");
      setM({ invoice: "", amount: "", ref: "" });
      void qc.invalidateQueries({ queryKey: ["get", "/payments"] });
      void qc.invalidateQueries({ queryKey: ["get", "/invoices"] });
    },
    onError: (e) => toast(errorMessage(e)),
  });
  return (
    <Screen eyebrow="Finance" title="Payments reconciliation" queries={[list]}>
      {({ locked }) => (
        <div className="space-y-5">
          <Card
            plain
            flush
            title="Ledger"
            actions={
              <select aria-label="Show" value={filter} onChange={(e) => setFilter(e.target.value)} className={inputCls + " w-auto"}>
                {[["", "All"], ["succeeded", "Succeeded"], ["pending", "Pending"], ["failed", "Failed"], ["stale", "Pending over 30 min"]].map(([v, l]) => (
                  <option key={v} value={v}>{l}</option>
                ))}
              </select>
            }
          >
            {rows.length === 0 ? (
              <p className="p-6 text-center text-mute">No payments match.</p>
            ) : (
              <DataTable
                cols={[
                  { key: "created_at", label: "Received", className: "whitespace-nowrap", render: (p) => fmtStamp(p.created_at!, me.school.timezone) },
                  { key: "provider_ref", label: "Reference", mono: true },
                  { key: "student", label: "For", render: (p) => <span>{p.student?.full_name} <span className="text-mute">{p.description}</span></span> },
                  { key: "method", label: "Method", render: (p) => METHOD[p.method!] ?? p.method },
                  { key: "amount", label: "Amount", mono: true, align: "right", render: (p) => money(p.amount) },
                  { key: "status", label: "Status", render: (p) => <Tag tone={p.status === "succeeded" ? "forest" : p.status === "failed" ? "alert" : "brass"}>{cap(p.status!)}</Tag> },
                  { key: "note", label: "", render: (p) => (p.status === "pending" ? <span className="text-xs text-mute">Awaiting the provider</span> : null) },
                ]}
                rows={rows}
              />
            )}
            <LoadMore q={list} />
          </Card>
          <Card title="Record a manual payment" eyebrow="Cash or bank deposit">
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              <Field label="Overdue invoice" className="lg:col-span-2">
                <select
                  className={inputCls}
                  value={m.invoice}
                  onChange={(e) => {
                    const i = open.find((x) => x.id === e.target.value);
                    setM({ ...m, invoice: e.target.value, amount: i?.outstanding ?? "" });
                  }}
                >
                  <option value="">Choose</option>
                  {open.map((i) => (
                    <option key={i.id} value={i.id}>{i.student!.full_name}, {i.description}, owes {money(i.outstanding)}</option>
                  ))}
                </select>
              </Field>
              <Field label="Amount (GH¢)"><input className={inputCls + " mono"} inputMode="decimal" value={m.amount} onChange={(e) => setM({ ...m, amount: e.target.value })} /></Field>
              <Field label="Receipt no."><input className={inputCls + " mono"} value={m.ref} onChange={(e) => setM({ ...m, ref: e.target.value })} /></Field>
            </div>
            <Btn
              className="mt-4"
              disabled={locked || !m.invoice || !POSITIVE_MONEY.test(m.amount) || !m.ref || record.isPending}
              onClick={() => record.mutate({ body: { invoice_id: m.invoice, amount: m.amount, reference: m.ref } })}
            >
              Record payment
            </Btn>
          </Card>
        </div>
      )}
    </Screen>
  );
}
