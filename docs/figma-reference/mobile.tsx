import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { announcements, assessments, bookedSlots, children, grades, homework, initialScores, invoices, kofiWeek, money, notifications, periodsToday, roster6A, runningAvg, slots, statedAvg, students, threads, type Status } from "./data";
import { Avatar, Banner, Btn, Icon, Link, StatusChip, Tag, go, invTone, useApp, type Role } from "./ui";

type SS = "live" | "loading" | "empty" | "error" | "offline" | "locked";
const MCtx = createContext<{ st: SS; toast: (m: string) => void }>({ st: "live", toast: () => {} });
const useM = () => useContext(MCtx);
const base = (r: Role) => `/m/${r}`;
const card = "rounded-reg border border-rule border-t-[3px] border-t-accent bg-raised p-4";
const btn = "min-h-11 w-full";

/* ---------- building blocks ---------- */
function MScreen({ title, eyebrow, back, big, action, emptyText = "Nothing here yet.", children, footer }: { title: string; eyebrow?: string; back?: string; big?: boolean; action?: ReactNode; emptyText?: string; children: (s: { locked: boolean; offline: boolean }) => ReactNode; footer?: ReactNode }) {
  const { st } = useM();
  const [, force] = useState(0);
  return (
    <>
      <header className="flex items-end gap-2 px-4 pt-2 pb-3">
        {back && <Link to={back} aria-label="Back" className="-ml-2 grid h-11 w-11 shrink-0 place-items-center text-accent"><span className="text-2xl leading-none">&lsaquo;</span></Link>}
        <div className="min-w-0 flex-1">
          {eyebrow && <div className="eyebrow">{eyebrow}</div>}
          <h1 className={`truncate ${big ? "text-[28px]" : "text-[22px]"}`}>{title}</h1>
        </div>
        {action}
      </header>
      <div className="flex-1 space-y-4 overflow-y-auto px-4 pb-6">
        {st === "loading" ? (
          <div aria-busy="true" className={card}>{[70, 100, 100, 80, 100].map((w, i) => <div key={i} className="skeleton mb-3 h-4" style={{ width: w + "%" }} />)}</div>
        ) : st === "empty" ? (
          <p className="rounded-reg border border-dashed border-rule p-8 text-center text-mute">{emptyText}</p>
        ) : st === "error" ? (
          <div role="alert" className="rounded-reg border border-alert bg-alert/10 p-4"><div className="font-semibold text-alert">Could not load this screen.</div><p className="mb-3 text-sm text-soft">No response from the server.</p><Btn variant="ghost" className="min-h-11" onClick={() => { window.dispatchEvent(new CustomEvent("m-state", { detail: "live" })); force((n) => n + 1); }}>Retry</Btn></div>
        ) : (
          <>
            {st === "locked" && <Banner tone="brass">Term 1 is closed. This screen is read-only.</Banner>}
            {children({ locked: st === "locked", offline: st === "offline" })}
          </>
        )}
      </div>
      {footer}
    </>
  );
}

function Row({ to, title, sub, right, onClick }: { to?: string; title: string; sub?: string; right?: ReactNode; onClick?: () => void }) {
  const inner = (
    <>
      <div className="min-w-0 flex-1"><div className="truncate font-semibold">{title}</div>{sub && <div className="truncate text-sm text-mute">{sub}</div>}</div>
      {right}
      {(to || onClick) && <span className="text-xl text-mute">&rsaquo;</span>}
    </>
  );
  const cls = "flex min-h-14 w-full items-center gap-3 border-b border-rule/70 px-4 py-2 text-left last:border-0 active:bg-accent-soft";
  return to ? <Link to={to} className={cls}>{inner}</Link> : onClick ? <button onClick={onClick} className={cls}>{inner}</button> : <div className={cls}>{inner}</div>;
}
const List = ({ children }: { children: ReactNode }) => <div className="overflow-hidden rounded-reg border border-rule bg-raised">{children}</div>;
const Tile = ({ label, value, sub, tone }: { label: string; value: string; sub?: string; tone?: boolean }) => (
  <div className={card}><div className="eyebrow">{label}</div><div className={`mono mt-0.5 text-2xl font-medium ${tone ? "text-alert" : ""}`}>{value}</div>{sub && <div className="text-sm text-mute">{sub}</div>}</div>
);

function Bubble({ from, text, time, file, mine }: { from: string; text: string; time: string; file?: string; mine: boolean }) {
  return (
    <div className={`flex ${mine ? "justify-end" : ""}`}>
      <div className={`max-w-[85%] rounded-reg border px-3 py-2 ${mine ? "border-accent bg-accent-soft" : "border-rule bg-raised"}`}>
        <div className="eyebrow mb-0.5">{from} · {time}</div><p>{text}</p>
        {file && <span className="mono mt-1 inline-flex items-center gap-1 text-xs text-accent"><Icon n="clip" size={13} />{file}</span>}
      </div>
    </div>
  );
}

function Sheet({ open, onClose, title, children }: { open: boolean; onClose: () => void; title: string; children: ReactNode }) {
  if (!open) return null;
  return (
    <div className="absolute inset-0 z-40 flex items-end bg-ink/40" onClick={onClose}>
      <div role="dialog" aria-label={title} onClick={(e) => e.stopPropagation()} className="w-full rounded-t-[12px] border-t-[3px] border-t-accent bg-raised p-4 pb-8">
        <div className="mx-auto mb-3 h-1 w-10 rounded-full bg-rule" />
        <h2 className="mb-2 text-xl">{title}</h2>{children}
        <Btn variant="ghost" className={btn + " mt-4"} onClick={onClose}>Close</Btn>
      </div>
    </div>
  );
}

function TabBar({ role, sub }: { role: Role; sub: string }) {
  const tabs = role === "parent"
    ? [["home", "Home", "home", ["home"]], ["attendance", "Attendance", "check", ["attendance"]], ["grades", "Grades", "chart", ["grades"]], ["fees", "Fees", "coin", ["fees"]], ["more", "More", "list", []]]
    : [["today", "Today", "home", ["today"]], ["classes", "Classes", "users", ["classes", "class", "gradebook"]], ["messages", "Messages", "mail", ["messages"]], ["more", "More", "list", []]];
  const known = tabs.flatMap((t) => t[3] as string[]);
  return (
    <nav aria-label="Tabs" className="flex border-t border-rule bg-raised">
      {tabs.map(([to, label, icon, m]) => {
        const on = (m as string[]).includes(sub) || (to === "more" && !known.includes(sub));
        return (
          <Link key={to as string} to={`${base(role)}/${to}`} aria-current={on ? "page" : undefined} className={`flex min-h-14 flex-1 flex-col items-center justify-center gap-0.5 border-t-2 text-[11px] font-semibold ${on ? "border-accent text-accent" : "border-transparent text-mute"}`}>
            <Icon n={icon as string} size={20} />{label}
          </Link>
        );
      })}
    </nav>
  );
}

/* ---------- shared screens ---------- */
function Splash() {
  useEffect(() => { const t = setTimeout(() => go("/m/signin"), 1600); return () => clearTimeout(t); }, []);
  return (
    <div className="flex flex-1 flex-col items-center justify-center bg-raised">
      <div className="font-serif text-5xl font-semibold">Homeroom</div>
      <div className="eyebrow mt-2">Greenfield Academy · Kumasi</div>
      <div className="mt-10 h-0.5 w-24 overflow-hidden bg-rule"><i className="block h-full w-1/2 animate-pulse bg-accent" /></div>
    </div>
  );
}

function SignIn() {
  const [who, setWho] = useState<"parent" | "teacher" | "both">("parent");
  const [phone, setPhone] = useState(false);
  const [otp, setOtp] = useState(false);
  const input = "min-h-11 w-full rounded-reg border border-rule bg-paper px-3";
  return (
    <div className="flex-1 overflow-y-auto p-5">
      <div className="pt-6"><div className="font-serif text-4xl font-semibold">Homeroom</div><p className="mt-1 text-mute">Sign in to Greenfield Academy</p></div>
      <div className="mt-6 grid grid-cols-3 gap-1" role="radiogroup" aria-label="Demo account">
        {([["parent", "Parent"], ["teacher", "Teacher"], ["both", "Both roles"]] as const).map(([k, l]) => <button key={k} role="radio" aria-checked={who === k} onClick={() => setWho(k)} className={`mono min-h-11 rounded-reg border text-xs font-semibold ${who === k ? "border-accent bg-accent text-on-accent" : "border-rule"}`}>{l}</button>)}
      </div>
      <form className="mt-5 space-y-4" onSubmit={(e) => { e.preventDefault(); if (phone && !otp) { setOtp(true); return; } go(who === "both" ? "/m/picker" : `/m/${who}/${who === "parent" ? "home" : "today"}`); }}>
        {who === "parent" && <div className="flex gap-4 text-sm"><label className="flex min-h-11 items-center gap-2"><input type="radio" checked={!phone} onChange={() => { setPhone(false); setOtp(false); }} className="accent-[var(--accent)]" />Email</label><label className="flex min-h-11 items-center gap-2"><input type="radio" checked={phone} onChange={() => setPhone(true)} className="accent-[var(--accent)]" />Phone and code</label></div>}
        {who === "parent" && phone ? (
          <>
            <label className="block"><span className="eyebrow mb-1 block">Mobile number</span><input className={input + " mono"} defaultValue="024 410 2231" /></label>
            {otp && <label className="block"><span className="eyebrow mb-1 block">6-digit code sent by SMS</span><input className={input + " mono tracking-[0.4em]"} defaultValue="482913" inputMode="numeric" /></label>}
          </>
        ) : (
          <>
            <label className="block"><span className="eyebrow mb-1 block">Email</span><input className={input} type="email" defaultValue={who === "teacher" ? "k.boateng@greenfield.edu.gh" : "akua.asante@mail.com"} /></label>
            <label className="block"><span className="eyebrow mb-1 block">Password</span><input className={input} type="password" defaultValue="password123" /></label>
          </>
        )}
        <Btn type="submit" className={btn}>{phone && who === "parent" ? (otp ? "Verify and sign in" : "Send code") : "Sign in"}</Btn>
        <button type="button" className="min-h-11 text-sm font-semibold text-accent">Forgot password</button>
      </form>
    </div>
  );
}

function Picker() {
  return (
    <div className="flex-1 space-y-3 p-5">
      <div className="pt-6"><div className="eyebrow">Your account has two roles</div><h1 className="text-3xl">Continue as</h1></div>
      {(["parent", "teacher"] as Role[]).map((r) => (
        <Link key={r} to={`/m/${r}/${r === "parent" ? "home" : "today"}`} data-portal={r} className={card + " block min-h-14"}><div className="font-serif text-xl font-semibold capitalize">{r}</div><div className="text-sm text-mute">{r === "parent" ? "Akua Asante, Kofi and Ama" : "Kwame Boateng, 6A homeroom"}</div></Link>
      ))}
    </div>
  );
}

function Notifs({ role }: { role: Role }) {
  return (
    <MScreen title="Notifications" back={`${base(role)}/more`} emptyText="You are all caught up.">
      {() => <List>{notifications.map((n) => <Row key={n.id} title={n.text} sub={`${n.kind} · ${n.time}`} />)}</List>}
    </MScreen>
  );
}

function Settings({ role }: { role: Role }) {
  const { theme, setTheme, toast } = useApp();
  return (
    <MScreen title="Profile and settings" back={`${base(role)}/more`}>
      {() => (
        <>
          <div className={card}><div className="eyebrow mb-2">Contact details</div><div className="font-semibold">{role === "parent" ? "Akua Asante" : "Kwame Boateng"}</div><div className="mono text-sm text-mute">024 410 2231</div><Btn variant="ghost" className="mt-3 min-h-11" onClick={() => toast("Edit details opened")}>Edit</Btn></div>
          <List>
            {["Push", "Email", "SMS"].map((c, i) => <label key={c} className="flex min-h-14 items-center justify-between border-b border-rule/70 px-4 last:border-0"><span className="font-semibold">{c}</span><input type="checkbox" defaultChecked={i !== 2} className="h-6 w-6 accent-[var(--accent)]" /></label>)}
            <Row to={`${base(role)}/sms`} title="Get alerts by SMS" sub="For when you do not have data" />
          </List>
          <div className="flex gap-2">{(["light", "dark"] as const).map((t) => <Btn key={t} variant={theme === t ? "primary" : "ghost"} className="min-h-11 flex-1 capitalize" onClick={() => setTheme(t)}>{t}</Btn>)}</div>
          <Btn variant="danger" className={btn} onClick={() => go("/m/signin")}>Sign out</Btn>
        </>
      )}
    </MScreen>
  );
}

function Sms({ role }: { role: Role }) {
  const { toast } = useApp();
  return (
    <MScreen title="SMS alerts" back={`${base(role)}/settings`}>
      {() => (
        <>
          <div className={card}><h2 className="text-xl">Get alerts by SMS if you don't have data</h2><p className="mt-2 text-soft">Homeroom can text you when something needs attention, so you do not need the app open or an internet connection.</p></div>
          <List>{["Your child is marked absent or late", "A fee is due in 3 days", "New homework is posted", "School announcements"].map((t) => <label key={t} className="flex min-h-14 items-center justify-between gap-3 border-b border-rule/70 px-4 last:border-0"><span>{t}</span><input type="checkbox" defaultChecked className="h-6 w-6 shrink-0 accent-[var(--accent)]" /></label>)}</List>
          <p className="text-sm text-mute">Standard SMS rates from your network apply. Messages are sent to 024 410 2231.</p>
          <Btn className={btn} onClick={() => toast("SMS alerts turned on")}>Turn on SMS alerts</Btn>
        </>
      )}
    </MScreen>
  );
}

function MessageList({ role }: { role: Role }) {
  const list = role === "teacher" ? threads.filter((t) => t.teacher === "Kwame Boateng") : threads.slice(0, 1);
  return (
    <MScreen big title="Messages" emptyText="No conversations yet.">
      {() => <List>{list.map((t) => <Row key={t.id} to={`${base(role)}/messages/${t.id}`} title={`${t.student} · ${t.section}`} sub={`${role === "teacher" ? t.guardian : t.teacher}: ${t.last}`} right={t.unread ? <i className="h-2.5 w-2.5 rounded-full bg-alert" /> : <span className="mono text-xs text-mute">{t.date}</span>} />)}</List>}
    </MScreen>
  );
}
function Thread({ role, id }: { role: Role; id: string }) {
  const { toast } = useApp();
  const t0 = threads.find((x) => x.id === id) ?? threads[0];
  const me = role === "parent" ? "Akua Asante" : "Kwame Boateng";
  const [msgs, setMsgs] = useState(t0.msgs);
  const [r, setR] = useState("");
  return (
    <MScreen title={t0.student} eyebrow={`${t0.section} · about this student`} back={`${base(role)}/messages`}
      footer={<div className="flex gap-2 border-t border-rule bg-raised p-3"><button aria-label="Attach file" onClick={() => toast("Attachment picker opened")} className="grid h-11 w-11 shrink-0 place-items-center rounded-reg border border-rule text-accent"><Icon n="clip" /></button><input aria-label="Message" value={r} onChange={(e) => setR(e.target.value)} placeholder="Message" className="min-h-11 min-w-0 flex-1 rounded-reg border border-rule bg-paper px-3" /><Btn className="min-h-11" disabled={!r} onClick={() => { setMsgs([...msgs, { from: me, text: r, time: "Just now" }]); setR(""); }}>Send</Btn></div>}>
      {() => <div className="space-y-3">{msgs.map((m, i) => <Bubble key={i} {...m} mine={m.from === me} />)}</div>}
    </MScreen>
  );
}

/* ---------- parent ---------- */
const inv = (id: string) => invoices.find((i) => i.studentId === id)!;
function ChildChips() {
  const { child, setChild } = useApp();
  return (
    <div role="tablist" aria-label="Child" className="flex gap-2">
      {children.map((c) => <button key={c.id} role="tab" aria-selected={child === c.id} onClick={() => setChild(c.id)} className={`flex min-h-12 flex-1 items-center gap-2 rounded-reg border px-2 text-left ${child === c.id ? "border-accent bg-accent-soft" : "border-rule bg-raised"}`}><Avatar name={c.full} /><span className="leading-tight"><span className="block font-semibold">{c.name}</span><span className="mono text-[11px] text-mute">{c.section}</span></span></button>)}
    </div>
  );
}
const useKid = () => { const { child } = useApp(); return children.find((c) => c.id === child) ?? children[0]; };

function PHome() {
  const c = useKid();
  const i = inv(c.id), bal = i.total - i.paid;
  const hw = c.id === "kofi" ? homework.filter((h) => h.section === "6A") : [];
  return (
    <MScreen big eyebrow="Tue 30 Sep" title="Good morning, Akua">
      {() => (
        <>
          <ChildChips />
          <div className={card}><div className="eyebrow">Attendance today</div><div className="mt-2 flex items-center gap-3"><StatusChip s="P" /><span className="text-sm text-mute">Marked 07:52</span></div></div>
          <div className="grid grid-cols-2 gap-3"><Tile label="Latest grade" value={c.id === "kofi" ? "72%" : "84%"} sub={c.id === "kofi" ? "Fractions test" : "Times tables"} /><Tile label="Homework due" value={String(Math.min(hw.length, 2))} sub={hw[0] ? hw[0].subject + ", " + hw[0].due.split(" ")[0] : "Nothing due"} /></div>
          <div className={card}>
            <div className="eyebrow">Balance owed</div>
            <div className={`mono mt-0.5 text-3xl font-medium ${bal ? "text-alert" : "text-forest"}`}>{money(bal)}</div>
            <div className="mb-3 text-sm text-mute">{bal ? "Overdue since 30 Sep" : "Paid in full"}</div>
            {bal > 0 && <Btn className={btn} onClick={() => go(`/m/parent/fees/pay/${i.id}`)}>Pay {money(bal)}</Btn>}
          </div>
          <Link to="/m/parent/announcements" className={card + " block"}><div className="eyebrow">{announcements[0].date} · Notice</div><div className="font-semibold">{announcements[0].title}</div><p className="text-sm text-soft">{announcements[0].body}</p></Link>
        </>
      )}
    </MScreen>
  );
}

const weeks = [[1, 2, 3, 4, 5], [8, 9, 10, 11, 12], [15, 16, 17, 18, 19], [22, 23, 24, 25, 26], [29, 30, 0, 0, 0]];
function PAttendance() {
  const c = useKid();
  const [day, setDay] = useState<number | null>(null);
  const st = (d: number): Status | null => d < 8 || d === 0 ? null : c.id === "ama" ? "P" : d === 10 ? "A" : d === 17 || d === 24 ? "L" : d === 26 ? "E" : "P";
  const note = (d: number) => (c.id === "kofi" ? kofiWeek.find((k) => k.date.startsWith(String(d)))?.note : undefined);
  const s = day ? st(day) : null;
  return (
    <MScreen big eyebrow="September 2026" title="Attendance" emptyText="No attendance recorded yet.">
      {() => (
        <>
          <ChildChips />
          <div className={card}>
            <div className="grid grid-cols-5 gap-1 text-center">
              {["Mon", "Tue", "Wed", "Thu", "Fri"].map((d) => <div key={d} className="eyebrow pb-1">{d}</div>)}
              {weeks.flat().map((d, i) => (
                <button key={i} disabled={!d || !st(d)} onClick={() => setDay(d)} className={`flex min-h-14 flex-col items-center justify-center rounded-reg border ${d ? "border-rule bg-paper" : "border-transparent"}`}>
                  {d > 0 && <span className="mono text-[11px] text-mute">{d}</span>}{d > 0 && st(d) && <StatusChip s={st(d)!} compact />}
                </button>
              ))}
            </div>
            <p className="mt-3 text-xs text-mute">Tap a day for details. School opened 8 Sep.</p>
          </div>
          <Sheet open={!!day} onClose={() => setDay(null)} title={`${day} Sep 2026`}>
            {s && <div className="space-y-2"><StatusChip s={s} />{note(day!) && <p className="text-soft">{note(day!)}</p>}{s === "E" && <Link to="/m/parent/messages/t1" className="block text-sm font-semibold text-accent">View the note thread</Link>}</div>}
          </Sheet>
        </>
      )}
    </MScreen>
  );
}

function PGrades() {
  const c = useKid();
  const [open, setOpen] = useState("Maths");
  return (
    <MScreen big eyebrow="Term 1" title="Grades" emptyText="No grades posted yet.">
      {() => (
        <>
          <ChildChips />
          {grades[c.id].map((s) => (
            <div key={s.subject} className={card + " !p-0"}>
              <button className="flex min-h-14 w-full items-center justify-between px-4 text-left" aria-expanded={open === s.subject} onClick={() => setOpen(open === s.subject ? "" : s.subject)}>
                <span><span className="block font-serif text-lg font-semibold">{s.subject}</span><span className="eyebrow">Running grade</span></span><span className="mono text-2xl">{s.running.toFixed(1)}%</span>
              </button>
              {open === s.subject && <ul className="divide-y divide-rule border-t border-rule px-4 text-sm">{s.items.map((i) => <li key={i.t} className="flex justify-between py-2.5"><span>{i.t} <span className="mono text-xs text-mute">{i.w}%</span></span><span className={`mono ${i.score.startsWith("Not") ? "text-mute" : ""}`}>{i.score}</span></li>)}</ul>}
            </div>
          ))}
        </>
      )}
    </MScreen>
  );
}

function PFees() {
  const receipts = [["15 Sep", "PAY-7688", 950], ["2 Sep", "PAY-7602", 300]];
  return (
    <MScreen big eyebrow="Term 1, 2026" title="Fees" emptyText="No invoices issued.">
      {({ locked }) => (
        <>
          <div className="eyebrow">Invoices</div>
          <List>
            {invoices.filter((i) => ["kofi", "ama"].includes(i.studentId)).map((i) => { const b = i.total - i.paid; return <Row key={i.id} title={`${i.student}: ${i.item}`} sub={b ? `${money(b)} due ${i.due}` : `Paid ${money(i.total)}`} right={<Tag tone={invTone(i.status)}>{i.status}</Tag>} />; })}
          </List>
          {inv("kofi").total > inv("kofi").paid && <Btn className={btn} disabled={locked} onClick={() => go(`/m/parent/fees/pay/${inv("kofi").id}`)}>Pay Kofi's balance</Btn>}
          <p className="rounded-reg border border-brass bg-brass-soft px-3 py-2 text-sm">A MoMo payment of GH¢ 300.00 is pending confirmation.</p>
          <div className="eyebrow">Receipts</div>
          <List>{receipts.map(([d, r, a]) => <Row key={r as string} title={r as string} sub={`Kofi · ${d}`} right={<span className="mono">{money(a as number)}</span>} />)}</List>
        </>
      )}
    </MScreen>
  );
}

type Step = "form" | "processing" | "success" | "failure" | "pending";
function PPay({ id }: { id: string }) {
  const i = invoices.find((x) => x.id === id) ?? invoices[0];
  const bal = i.total - i.paid;
  const { toast } = useApp();
  const [amt, setAmt] = useState(String(bal));
  const [method, setMethod] = useState("Card");
  const [step, setStep] = useState<Step>("form");
  const [tries, setTries] = useState(0);
  const n = Number(amt), valid = n > 0 && n <= bal;
  const run = () => { setStep("processing"); setTimeout(() => { setTries((t) => t + 1); setStep(method === "Card" ? "success" : method === "MTN MoMo" ? "pending" : tries === 0 ? "failure" : "success"); }, 1400); };
  return (
    <MScreen title="Pay fees" eyebrow={`${i.student} · ${i.id}`} back="/m/parent/fees"
      footer={step === "form" ? <div className="border-t border-rule bg-raised p-3"><Btn className={btn} disabled={!valid} onClick={run}>Pay {valid ? money(n) : ""}</Btn></div> : undefined}>
      {() => (
        <>
          {step === "form" && (
            <>
              <label className="block"><span className="eyebrow mb-1 block">Amount (GH¢)</span><input inputMode="decimal" value={amt} onChange={(e) => setAmt(e.target.value)} className="mono min-h-12 w-full rounded-reg border border-rule bg-paper px-3 text-xl" /><span className={`text-sm ${valid ? "text-mute" : "text-alert"}`}>{valid ? `Balance ${money(bal)}` : `Enter up to ${money(bal)}`}</span></label>
              <fieldset><legend className="eyebrow mb-1">Method</legend><div className="space-y-2">{["Card", "MTN MoMo", "Telecel Cash"].map((m) => <label key={m} className={`flex min-h-12 items-center gap-3 rounded-reg border px-3 ${method === m ? "border-accent bg-accent-soft" : "border-rule bg-raised"}`}><input type="radio" name="pm" checked={method === m} onChange={() => setMethod(m)} className="h-5 w-5 accent-[var(--accent)]" />{m}</label>)}</div></fieldset>
              <p className="text-xs text-mute">Demo: Card succeeds, MTN MoMo stays pending, Telecel Cash fails once then succeeds.</p>
            </>
          )}
          {step === "processing" && <div role="status" className={card + " py-10 text-center"}><div className="mx-auto mb-4 h-8 w-8 animate-spin rounded-full border-2 border-rule border-t-accent" /><div className="font-semibold">Processing {money(n)}</div><p className="text-sm text-mute">{method === "Card" ? "Contacting your bank." : "Approve the prompt on your phone."}</p></div>}
          {step === "success" && <div className={card}><Tag tone="forest">Paid</Tag><h2 className="mt-2 text-2xl">Payment received</h2><div className="mono my-3 space-y-1 text-sm"><div>Receipt PAY-7740</div><div>{money(n)} via {method}</div></div><Btn className={btn} onClick={() => toast("Receipt saved")}>Save receipt</Btn><Btn variant="ghost" className={btn + " mt-2"} onClick={() => go("/m/parent/fees")}>Done</Btn></div>}
          {step === "failure" && <div role="alert" className={card}><Tag tone="alert">Failed</Tag><h2 className="mt-2 text-2xl">Payment did not go through</h2><p className="my-2 text-soft">The prompt timed out. You have not been charged.</p><Btn className={btn} onClick={run}>Retry</Btn><Btn variant="ghost" className={btn + " mt-2"} onClick={() => setStep("form")}>Change method</Btn></div>}
          {step === "pending" && <div className={card}><Tag tone="brass">Pending confirmation</Tag><h2 className="mt-2 text-2xl">Waiting for MTN</h2><p className="my-2 text-soft">We have not heard back about your {money(n)} payment yet. Your balance updates once it is confirmed. You can leave this screen.</p><Btn className={btn} onClick={() => go("/m/parent/fees")}>Back to fees</Btn></div>}
        </>
      )}
    </MScreen>
  );
}

function PMore() {
  const b = "/m/parent";
  return (
    <MScreen big title="More">
      {() => (
        <>
          <List>{[["reports", "Report cards"], ["homework", "Homework"], ["messages", "Messages"], ["announcements", "Announcements"], ["conference", "Book a conference"]].map(([p, l]) => <Row key={p} to={`${b}/${p}`} title={l} />)}</List>
          <List><Row to={`${b}/notifications`} title="Notifications" /><Row to={`${b}/push`} title="Push notification previews" /><Row to={`${b}/settings`} title="Profile and settings" /></List>
        </>
      )}
    </MScreen>
  );
}
function PReports() {
  const { toast } = useApp();
  return <MScreen title="Report cards" back="/m/parent/more" emptyText="No report cards yet.">{() => <List><Row title="Term 1, 2026" sub="Available after 18 Dec" right={<Tag>Not issued</Tag>} /><Row title="Term 3, 2025" sub="Issued 19 Dec 2025" onClick={() => toast("Report card downloaded")} /></List>}</MScreen>;
}
function PHomework({ id }: { id?: string }) {
  const hw = homework.filter((h) => h.section === "6A");
  const h = hw.find((x) => x.id === id);
  if (id && h) return <MScreen title={h.title} eyebrow={h.subject} back="/m/parent/homework">{() => <div className={card}><div className="eyebrow">Due</div><div className="mono mb-3 text-lg">{h.due}</div><div className="eyebrow">Posted</div><div className="mb-3">{h.posted} by Kwame Boateng</div>{h.file && <span className="mono inline-flex items-center gap-1 text-sm text-accent"><Icon n="clip" size={14} />{h.file}</span>}</div>}</MScreen>;
  return <MScreen title="Homework" back="/m/parent/more" emptyText="No homework this week.">{() => <List>{hw.map((x) => <Row key={x.id} to={`/m/parent/homework/${x.id}`} title={`${x.subject}: ${x.title}`} sub={`Due ${x.due}`} />)}</List>}</MScreen>;
}
function PAnnouncements() {
  const [resp, setResp] = useState<string | null>(null);
  return (
    <MScreen title="Announcements" back="/m/parent/more" emptyText="No announcements.">
      {({ locked }) => <>{announcements.filter((a) => a.id !== "a3").map((a) => (
        <div key={a.id} className={card}><div className="eyebrow">{a.date}</div><h2 className="text-lg">{a.title}</h2><p className="mt-1 text-soft">{a.body}</p>
          {a.slip && <div className="mt-3 border-t border-rule pt-3"><div className="eyebrow mb-2">Permission slip for Kofi · reply by 7 Nov</div>{resp ? <div className="flex items-center justify-between"><Tag tone={resp === "Yes" ? "forest" : "alert"}>{resp === "Yes" ? "Permission given" : "Declined"}</Tag><button className="min-h-11 text-sm font-semibold text-accent" onClick={() => setResp(null)}>Change</button></div> : <div className="flex gap-2"><Btn className="min-h-11 flex-1" disabled={locked} onClick={() => setResp("Yes")}>Yes</Btn><Btn variant="ghost" className="min-h-11 flex-1" disabled={locked} onClick={() => setResp("No")}>No</Btn></div>}</div>}
        </div>))}</>}
    </MScreen>
  );
}
function PConference() {
  const { toast } = useApp();
  const [mine, setMine] = useState("09:15");
  const [pick, setPick] = useState<string | null>(null);
  const [done, setDone] = useState(false);
  return (
    <MScreen title="Book a conference" eyebrow="Kwame Boateng · Sat 25 Oct" back="/m/parent/more" emptyText="No slots open.">
      {({ locked }) => done ? (
        <div className={card}><Tag tone="forest">Booked</Tag><h2 className="mt-2 text-2xl">See you at {mine}</h2><p className="my-2 text-soft">Saturday 25 October with Kwame Boateng, 15 minutes, about Kofi.</p><Btn className={btn} onClick={() => toast("Added to calendar")}>Add to calendar</Btn><Btn variant="ghost" className={btn + " mt-2"} onClick={() => setDone(false)}>Change slot</Btn></div>
      ) : (
        <>
          <p className="text-sm text-mute">You are booked for <b className="mono">{mine}</b>. Pick another slot to move it.</p>
          <div className="grid grid-cols-3 gap-2">{slots.map((s) => { const taken = bookedSlots[s] && s !== mine; return <button key={s} disabled={!!taken || locked} onClick={() => setPick(s)} className={`mono min-h-14 rounded-reg border text-sm font-semibold disabled:opacity-40 ${s === mine ? "border-accent bg-accent-soft" : pick === s ? "border-accent ring-2 ring-accent" : "border-rule bg-raised"}`}>{s}<span className="block font-sans text-[11px] font-normal text-mute">{s === mine ? "Yours" : taken ? "Taken" : "Open"}</span></button>; })}</div>
          <Btn className={btn} disabled={locked} onClick={() => { if (pick) setMine(pick); setPick(null); setDone(true); }}>{pick ? `Book ${pick}` : "Confirm current slot"}</Btn>
        </>
      )}
    </MScreen>
  );
}
function PPush() {
  const items = [["Kofi marked absent", "Kofi was marked absent in Period 1 today. Tap to message Mr Boateng.", "07:58"], ["Fee due in 3 days", "GH¢ 600.00 tuition for Kofi is due on 30 Sep.", "Sun 27 Sep"], ["Homework posted", "Maths: exercises 4.2 to 4.5, due Thu.", "Mon 15:10"], ["Announcement", "Mid-term break: school closes Fri 24 Oct, reopens Mon 3 Nov.", "Sat 27 Sep"]];
  return (
    <MScreen title="Push previews" back="/m/parent/more">
      {() => <>{items.map(([t, b, w]) => <div key={t} className="flex gap-3 rounded-[12px] border border-rule bg-raised p-3"><span className="grid h-10 w-10 shrink-0 place-items-center rounded-reg bg-accent font-serif text-lg font-semibold text-on-accent">H</span><div className="min-w-0"><div className="flex justify-between gap-2"><span className="font-semibold">{t}</span><span className="mono text-[11px] text-mute">{w}</span></div><p className="text-sm text-soft">{b}</p></div></div>)}</>}
    </MScreen>
  );
}

/* ---------- teacher ---------- */
function TToday() {
  return (
    <MScreen big eyebrow="Tue 30 Sep" title="Good morning, Kwame" emptyText="No periods today.">
      {() => (
        <>
          <div className="rounded-reg border border-alert bg-alert/10 p-4"><div className="font-semibold text-alert">3 registers unmarked</div><p className="mb-3 text-sm text-soft">Next: Period 3, Maths, 6B</p><Btn className={btn} onClick={() => go("/m/teacher/attendance/6B/p3")}>Take attendance now</Btn></div>
          <List>{periodsToday.map((p) => <Row key={p.id} to={`/m/teacher/attendance/${p.section}/${p.id}`} title={`${p.label}: ${p.subject} ${p.section}`} sub={p.time} right={p.marked ? <Tag tone="forest">Marked</Tag> : <Tag tone="alert">Unmarked</Tag>} />)}</List>
        </>
      )}
    </MScreen>
  );
}

function TAttendance({ sec, pid }: { sec: string; pid: string }) {
  const { st } = useM();
  const { toast } = useApp();
  const roster = students.filter((s) => s.section === sec).slice(0, 8);
  const p = periodsToday.find((x) => x.id === pid) ?? periodsToday[2];
  const [m, setM] = useState<Record<string, Status>>({});
  const [saved, setSaved] = useState<null | "device" | "synced">(null);
  const n = roster.filter((s) => m[s.id]).length;
  const offline = st === "offline";
  return (
    <MScreen title={`${p.subject} ${sec}`} eyebrow={`${p.label} · ${p.time}`} back="/m/teacher/today" emptyText="No students in this section."
      footer={
        <div className="space-y-2 border-t border-rule bg-raised p-3">
          <div className="flex items-center gap-3"><span className="mono text-sm"><b>{n}</b>/{roster.length}</span><div className="h-2 flex-1 overflow-hidden rounded-full border border-rule"><i className="block h-full bg-accent transition-all" style={{ width: (n / roster.length) * 100 + "%" }} /></div></div>
          <Btn className={btn} disabled={n < roster.length || st === "locked"} onClick={() => { if (offline) setSaved("device"); else { setSaved("synced"); toast("Register saved"); } }}>{n < roster.length ? `Mark ${roster.length - n} more to save` : "Save register"}</Btn>
        </div>
      }>
      {({ locked }) => (
        <>
          {offline && <Banner tone="alert">You are offline. Saving keeps the register on this device.</Banner>}
          {saved === "device" && <div className="rounded-reg border border-forest bg-forest-soft p-3 text-sm"><b>Saved on device.</b> It will sync when you are back online.<Btn variant="ghost" className="mt-2 min-h-11 w-full" onClick={() => { setSaved("synced"); toast("Sync complete"); }}>Simulate reconnect</Btn></div>}
          {saved === "synced" && <Banner tone="forest">Sync complete. The register for {sec} is up to date.</Banner>}
          <Btn variant="ghost" className={btn} disabled={locked} onClick={() => { setM(Object.fromEntries(roster.map((s) => [s.id, "P" as Status]))); setSaved(null); }}>Mark all present</Btn>
          <div className="overflow-hidden rounded-reg border border-rule bg-raised">
            {roster.map((s, i) => (
              <div key={s.id} className="flex items-center gap-2 border-b border-rule/70 px-3 py-1.5 last:border-0">
                <span className="mono w-4 text-[11px] text-mute">{i + 1}</span>
                <span className="min-w-0 flex-1 truncate text-[15px] font-semibold">{s.name}</span>
                <div role="radiogroup" aria-label={s.name} className="flex gap-0.5">
                  {(["P", "L", "A", "E"] as Status[]).map((k) => {
                    const on = m[s.id] === k;
                    const tone = { P: "border-forest bg-forest text-on-accent", L: "border-brass bg-brass text-on-accent", A: "border-alert bg-alert text-on-accent", E: "border-mute bg-mute text-on-accent" }[k];
                    return <button key={k} role="radio" aria-checked={on} aria-label={k} disabled={locked} onClick={() => { setM({ ...m, [s.id]: k }); setSaved(null); }} className={`mono h-11 w-11 rounded-reg border text-sm font-semibold disabled:opacity-50 ${on ? tone : "border-rule text-mute"}`}>{k}</button>;
                  })}
                </div>
              </div>
            ))}
          </div>
          <p className="text-center text-xs text-mute">Showing 8 of {sec === "6A" ? 28 : 27} students</p>
        </>
      )}
    </MScreen>
  );
}

function TClasses() {
  return (
    <MScreen big title="Classes" emptyText="No classes assigned.">
      {() => <>{[["6A", "Homeroom and Maths", "94.5%", "79.2%", 28], ["6B", "Maths", "93.8%", "74.6%", 27]].map(([s, r, a, g, c]) => <Link key={s as string} to={`/m/teacher/class/${s}`} className={card + " block"}><div className="flex items-baseline justify-between"><h2 className="text-2xl">{s}</h2><span className="eyebrow">{c} students</span></div><div className="text-sm text-mute">{r}</div><div className="mono mt-2 flex gap-5 text-sm"><span>Att {a}</span><span>Avg {g}</span></div></Link>)}</>}
    </MScreen>
  );
}
function TClass({ sec }: { sec: string }) {
  const rows = students.filter((s) => s.section === sec);
  return (
    <MScreen title={`Section ${sec}`} back="/m/teacher/classes" eyebrow="Class overview">
      {() => (
        <>
          <div className="flex gap-2"><Btn className="min-h-11 flex-1" onClick={() => go(`/m/teacher/attendance/${sec}/p5`)}>Attendance</Btn><Btn variant="ghost" className="min-h-11 flex-1" onClick={() => go("/m/teacher/gradebook")}>Gradebook</Btn></div>
          <List>{rows.map((s) => { const a = statedAvg[s.id] ?? (initialScores[s.id] ? runningAvg(initialScores[s.id]) : null); return <Row key={s.id} title={s.name} sub={`Attendance ${s.att}%`} right={<span className="mono font-semibold">{a ? a.toFixed(1) + "%" : "n/a"}</span>} />; })}</List>
          <p className="text-center text-xs text-mute">Showing a sample of {sec === "6A" ? 28 : 27} students</p>
        </>
      )}
    </MScreen>
  );
}

function TGradebook() {
  const { toast } = useApp();
  const [ai, setAi] = useState(1);
  const [si, setSi] = useState(0);
  const [buf, setBuf] = useState("");
  const [sc, setSc] = useState(() => Object.fromEntries(assessments.map((_, i) => [i, Object.fromEntries(roster6A.map((s) => [s.id, initialScores[s.id][i]]))])) as Record<number, Record<string, number | null>>);
  const a = assessments[ai], s = roster6A[si];
  const vals = Object.values(sc[ai]).filter((v): v is number => v != null);
  const avg = vals.length ? (vals.reduce((t, v) => t + (v / a.max) * 100, 0) / vals.length) : null;
  const shown = buf !== "" ? buf : sc[ai][s.id] != null ? String(sc[ai][s.id]) : "";
  const commit = () => {
    if (buf !== "") setSc({ ...sc, [ai]: { ...sc[ai], [s.id]: Math.min(a.max, Number(buf)) } });
    setBuf("");
    if (si < roster6A.length - 1) setSi(si + 1); else toast("All scores entered");
  };
  return (
    <MScreen title="Gradebook" eyebrow="6A · Maths · lite" back="/m/teacher/classes" emptyText="No assessments yet."
      action={<Link to="/m/teacher/gradebook/new" className="grid min-h-11 place-items-center px-2 text-sm font-semibold text-accent">New</Link>}>
      {({ locked, offline }) => (
        <>
          {offline && <Banner tone="alert">Offline. Scores are saved on this device and will sync later.</Banner>}
          <div className="-mx-4 flex gap-2 overflow-x-auto px-4">{assessments.map((x, i) => <button key={x.id} onClick={() => { setAi(i); setSi(0); setBuf(""); }} className={`min-h-11 shrink-0 rounded-reg border px-3 text-sm font-semibold ${i === ai ? "border-accent bg-accent text-on-accent" : "border-rule bg-raised"}`}>{x.title}</button>)}</div>
          <div className="mono flex justify-between text-xs text-mute"><span>Weight {a.weight}% · out of {a.max}</span><span>Class avg {avg ? avg.toFixed(1) + "%" : "n/a"}</span></div>
          <div className={card}>
            <div className="flex items-center justify-between"><span className="eyebrow">Student {si + 1} of {roster6A.length}</span><div className="flex gap-1"><button aria-label="Previous" disabled={si === 0} onClick={() => { setSi(si - 1); setBuf(""); }} className="h-11 w-11 rounded-reg border border-rule disabled:opacity-40">&lsaquo;</button><button aria-label="Next" disabled={si === roster6A.length - 1} onClick={() => { setSi(si + 1); setBuf(""); }} className="h-11 w-11 rounded-reg border border-rule disabled:opacity-40">&rsaquo;</button></div></div>
            <div className="font-serif text-2xl font-semibold">{s.name}</div>
            <div className="mono my-2 text-5xl font-medium">{shown || <span className="text-rule">--</span>}<span className="text-xl text-mute"> /{a.max}</span></div>
            <div className="grid grid-cols-3 gap-2">
              {["1", "2", "3", "4", "5", "6", "7", "8", "9", "del", "0", "next"].map((k) => (
                <button key={k} disabled={locked} aria-label={k === "del" ? "Delete" : k === "next" ? "Save and next" : k} onClick={() => k === "del" ? setBuf(buf.slice(0, -1)) : k === "next" ? commit() : setBuf((buf + k).slice(0, 3))} className={`mono h-14 rounded-reg border text-xl font-medium disabled:opacity-50 ${k === "next" ? "border-accent bg-accent text-on-accent text-sm" : "border-rule bg-paper"}`}>{k === "del" ? "⌫" : k === "next" ? "Save" : k}</button>
              ))}
            </div>
          </div>
          <List>{roster6A.map((x, i) => <Row key={x.id} onClick={() => { setSi(i); setBuf(""); }} title={x.name} right={<span className={`mono ${i === si ? "font-semibold text-accent" : ""}`}>{sc[ai][x.id] ?? "--"}</span>} />)}</List>
        </>
      )}
    </MScreen>
  );
}
function TNewAssessment() {
  const { toast } = useApp();
  const f = "min-h-11 w-full rounded-reg border border-rule bg-paper px-3";
  return (
    <MScreen title="New assessment" back="/m/teacher/gradebook">
      {({ locked }) => (
        <>
          {[["Title", "Decimals quiz"], ["Weight (%)", "10"], ["Out of", "20"], ["Due date", "24 Oct"]].map(([l, v]) => <label key={l} className="block"><span className="eyebrow mb-1 block">{l}</span><input className={f} defaultValue={v} /></label>)}
          <Btn className={btn} disabled={locked} onClick={() => { toast("Assessment added"); go("/m/teacher/gradebook"); }}>Add assessment</Btn>
        </>
      )}
    </MScreen>
  );
}
function THomework() {
  const { toast } = useApp();
  const [list, setList] = useState(homework);
  const [t, setT] = useState("");
  return (
    <MScreen title="Homework" back="/m/teacher/more" emptyText="No homework posted.">
      {({ locked }) => (
        <>
          <div className={card + " space-y-3"}>
            <input aria-label="Task" value={t} onChange={(e) => setT(e.target.value)} placeholder="Task, e.g. Exercises 4.6 to 4.8" className="min-h-11 w-full rounded-reg border border-rule bg-paper px-3" />
            <div className="flex gap-2"><input aria-label="Due" defaultValue="Thu 2 Oct" className="mono min-h-11 min-w-0 flex-1 rounded-reg border border-rule bg-paper px-3" /><Btn variant="ghost" className="min-h-11" onClick={() => toast("Attachment picker opened")}>Attach</Btn></div>
            <Btn className={btn} disabled={locked || !t} onClick={() => { setList([{ id: "n" + list.length, subject: "Maths", title: t, due: "Thu 2 Oct", section: "6A", posted: "Today", file: "" }, ...list]); setT(""); toast("Posted to guardians"); }}>Post homework</Btn>
          </div>
          <List>{list.map((h) => <Row key={h.id} title={h.title} sub={`${h.subject} · ${h.section} · due ${h.due}`} />)}</List>
        </>
      )}
    </MScreen>
  );
}
function TConferences() {
  return (
    <MScreen title="Conferences" eyebrow="Sat 25 Oct" back="/m/teacher/more" emptyText="No slots today.">
      {() => <List>{slots.map((s) => <Row key={s} title={bookedSlots[s] ?? "Open"} sub={s} right={bookedSlots[s] ? <Tag tone="accent">Booked</Tag> : undefined} />)}</List>}
    </MScreen>
  );
}
function TMore() {
  const b = "/m/teacher";
  return <MScreen big title="More">{() => <><List><Row to={`${b}/gradebook`} title="Gradebook lite" /><Row to={`${b}/homework`} title="Homework" /><Row to={`${b}/conferences`} title="Conference schedule" /></List><List><Row to={`${b}/notifications`} title="Notifications" /><Row to={`${b}/settings`} title="Profile and settings" /></List></>}</MScreen>;
}

/* ---------- shell and prototype controls ---------- */
const INDEX: [string, [string, string][]][] = [
  ["Shared", [["Splash", "/m"], ["SignIn", "/m/signin"], ["RolePicker", "/m/picker"]]],
  ["Parent", [["Home", "/m/parent/home"], ["Attendance", "/m/parent/attendance"], ["Grades", "/m/parent/grades"], ["Fees", "/m/parent/fees"], ["Pay", "/m/parent/fees/pay/INV-1042"], ["More", "/m/parent/more"], ["Reports", "/m/parent/reports"], ["Homework", "/m/parent/homework"], ["Messages", "/m/parent/messages"], ["Announcements", "/m/parent/announcements"], ["Conference", "/m/parent/conference"], ["PushPreviews", "/m/parent/push"], ["SmsFallback", "/m/parent/sms"], ["Settings", "/m/parent/settings"]]],
  ["Teacher", [["Today", "/m/teacher/today"], ["TakeAttendance", "/m/teacher/attendance/6A/p5"], ["Classes", "/m/teacher/classes"], ["Gradebook", "/m/teacher/gradebook"], ["NewAssessment", "/m/teacher/gradebook/new"], ["Messages", "/m/teacher/messages"], ["Homework", "/m/teacher/homework"], ["Conferences", "/m/teacher/conferences"], ["More", "/m/teacher/more"]]],
];

export default function MobileApp({ path }: { path: string }) {
  const { theme, setTheme, setChild } = useApp();
  const p = path.split("/").filter(Boolean).slice(1);
  const role: Role | null = p[0] === "parent" || p[0] === "teacher" ? p[0] : null;
  const sub = role ? p[1] ?? "" : "";
  const [st, setSt] = useState<SS>("live");
  const [msg, setMsg] = useState<string | null>(null);
  useEffect(() => { setSt("live"); }, [path]);
  useEffect(() => { const f = (e: Event) => setSt((e as CustomEvent).detail); window.addEventListener("m-state", f); return () => window.removeEventListener("m-state", f); }, []);
  useEffect(() => { if (!msg) return; const t = setTimeout(() => setMsg(null), 2400); return () => clearTimeout(t); }, [msg]);

  let body: ReactNode;
  let tabs = !!role;
  if (!role) { body = p[0] === "signin" ? <SignIn /> : p[0] === "picker" ? <Picker /> : <Splash />; }
  else if (role === "parent") {
    const detail = (sub === "fees" && p[2]) || (sub === "messages" && p[2]) || (sub === "homework" && p[2]);
    tabs = !detail;
    body = sub === "attendance" ? <PAttendance /> : sub === "grades" ? <PGrades /> : sub === "fees" ? (p[2] === "pay" ? <PPay id={p[3]} /> : <PFees />) : sub === "more" ? <PMore /> : sub === "reports" ? <PReports /> : sub === "homework" ? <PHomework id={p[2]} /> : sub === "messages" ? (p[2] ? <Thread role="parent" id={p[2]} /> : <MessageList role="parent" />) : sub === "announcements" ? <PAnnouncements /> : sub === "conference" ? <PConference /> : sub === "push" ? <PPush /> : sub === "notifications" ? <Notifs role="parent" /> : sub === "settings" ? <Settings role="parent" /> : sub === "sms" ? <Sms role="parent" /> : <PHome />;
  } else {
    tabs = !(sub === "attendance" || (sub === "messages" && p[2]));
    body = sub === "attendance" ? <TAttendance sec={p[2] ?? "6A"} pid={p[3] ?? "p5"} /> : sub === "classes" ? <TClasses /> : sub === "class" ? <TClass sec={p[2] ?? "6A"} /> : sub === "gradebook" ? (p[2] === "new" ? <TNewAssessment /> : <TGradebook />) : sub === "messages" ? (p[2] ? <Thread role="teacher" id={p[2]} /> : <MessageList role="teacher" />) : sub === "more" ? <TMore /> : sub === "homework" ? <THomework /> : sub === "conferences" ? <TConferences /> : sub === "notifications" ? <Notifs role="teacher" /> : sub === "settings" ? <Settings role="teacher" /> : sub === "sms" ? <Sms role="teacher" /> : <TToday />;
  }
  const states: SS[] = ["live", "loading", "empty", "error", "locked", "offline"];
  return (
    <div className="flex min-h-dvh items-start justify-center gap-8 bg-rule/50 md:p-6 lg:items-center">
      <aside className="hidden w-60 shrink-0 self-start lg:block" style={{ maxHeight: "calc(100dvh - 48px)", overflowY: "auto" }}>
        <div className="eyebrow mb-1">Prototype controls</div>
        <div className="mb-3 rounded-reg border border-rule bg-raised p-3 text-sm">
          <label className="mb-2 flex items-center justify-between gap-2"><span className="eyebrow">State</span><select value={st} onChange={(e) => setSt(e.target.value as SS)} className="mono min-h-9 rounded-reg border border-rule bg-paper px-2 text-xs">{states.map((s) => <option key={s}>{s}</option>)}</select></label>
          <label className="flex items-center justify-between gap-2"><span className="eyebrow">Theme</span><button onClick={() => setTheme(theme === "light" ? "dark" : "light")} className="mono min-h-9 rounded-reg border border-rule bg-paper px-3 text-xs">{theme}</button></label>
        </div>
        {INDEX.map(([g, items]) => (
          <div key={g} className="mb-3"><div className="eyebrow mb-1">{g}</div><div className="flex flex-wrap gap-1">{items.map(([n, to]) => <Link key={n} to={to} onClick={() => g === "Parent" && setChild("kofi")} className={`mono rounded-reg border px-2 py-1 text-[11px] ${path === to ? "border-ink bg-ink text-paper" : "border-rule bg-raised hover:bg-paper"}`}>{g}/{n}</Link>)}</div></div>
        ))}
        <Link to="/signin" className="mono text-xs text-mute underline">Back to web app</Link>
      </aside>
      <MCtx.Provider value={{ st, toast: setMsg }}>
        <div data-portal={role ?? "teacher"} className="relative flex h-dvh w-full flex-col overflow-hidden bg-paper pt-[env(safe-area-inset-top)] pb-[env(safe-area-inset-bottom)] text-ink md:h-[844px] md:max-h-[calc(100dvh-48px)] md:w-[390px] md:shrink-0 md:rounded-[36px] md:border-[6px] md:border-ink md:pt-0">
          <div className="hidden h-11 shrink-0 items-center justify-between px-7 md:flex"><span className="mono text-sm font-semibold">9:41</span><span className="mono text-xs">{st === "offline" ? "no signal" : "5G"}</span></div>
          {body}
          {tabs && role && <TabBar role={role} sub={sub} />}
          <div className="hidden h-5 shrink-0 items-center justify-center md:flex"><i className="h-1 w-28 rounded-full bg-ink/60" /></div>
          {msg && <div role="status" className="absolute inset-x-4 bottom-24 z-50 rounded-reg border border-rule border-l-[3px] border-l-forest bg-raised px-4 py-3 text-sm shadow-lg">{msg}</div>}
        </div>
      </MCtx.Provider>
    </div>
  );
}
