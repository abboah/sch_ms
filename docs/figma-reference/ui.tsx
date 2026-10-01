import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { school, type Status } from "./data";

export type Role = "admin" | "teacher" | "parent";

/* ---------- router ---------- */
export function usePath() {
  const get = () => window.location.hash.slice(1) || "/signin";
  const [p, setP] = useState(get);
  useEffect(() => {
    const f = () => {
      setP(get());
      window.scrollTo(0, 0);
    };
    window.addEventListener("hashchange", f);
    return () => window.removeEventListener("hashchange", f);
  }, []);
  return p;
}
export const go = (to: string) => {
  window.location.hash = to;
};
export function Link({ to, className = "", children, ...rest }: { to: string; className?: string; children: ReactNode } & React.AnchorHTMLAttributes<HTMLAnchorElement>) {
  return (
    <a href={"#" + to} className={className} {...rest}>
      {children}
    </a>
  );
}

/* ---------- app context ---------- */
type Ctx = { theme: "light" | "dark"; setTheme: (t: "light" | "dark") => void; toast: (m: string) => void; role: Role; child: string; setChild: (c: string) => void };
export const AppCtx = createContext<Ctx>(null as unknown as Ctx);
export const useApp = () => useContext(AppCtx);

/* ---------- icons ---------- */
const P: Record<string, string> = {
  home: "M3 11l9-8 9 8M5 10v10h14V10",
  users: "M15 8a3 3 0 10-6 0 3 3 0 006 0zM4 21c0-4 4-6 8-6s8 2 8 6",
  book: "M4 4h10a4 4 0 014 4v12H8a4 4 0 01-4-4V4z",
  check: "M4 12l5 5L20 6",
  cal: "M4 6h16v14H4zM4 10h16M9 3v4M15 3v4",
  coin: "M12 3a9 9 0 100 18 9 9 0 000-18zM9 10h6M9 14h6",
  mail: "M3 6h18v12H3zM3 7l9 7 9-7",
  bell: "M6 17v-6a6 6 0 0112 0v6l2 2H4zM10 21h4",
  chart: "M4 20V4M4 20h16M8 16l4-5 3 3 5-7",
  list: "M8 6h12M8 12h12M8 18h12M4 6h.01M4 12h.01M4 18h.01",
  grid: "M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z",
  mega: "M3 11v3h4l8 5V6L7 11zM19 9v6",
  shield: "M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6z",
  file: "M6 3h8l4 4v14H6zM14 3v4h4",
  sun: "M12 8a4 4 0 100 8 4 4 0 000-8zM12 2v2M12 20v2M2 12h2M20 12h2",
  moon: "M20 14A8 8 0 0110 4a8 8 0 1010 10z",
  search: "M11 4a7 7 0 100 14 7 7 0 000-14zM21 21l-5-5",
  pen: "M4 20l4-1 11-11-3-3L5 16z",
  clip: "M8 12l6-6a3 3 0 014 4l-8 8a5 5 0 01-7-7l7-7",
};
export function Icon({ n, size = 18 }: { n: string; size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <path d={P[n] ?? P.file} />
    </svg>
  );
}

/* ---------- primitives ---------- */
export function Btn({ children, variant = "primary", className = "", ...r }: { variant?: "primary" | "ghost" | "danger" } & React.ButtonHTMLAttributes<HTMLButtonElement>) {
  const v = {
    primary: "bg-accent text-on-accent border-accent hover:opacity-90",
    ghost: "bg-transparent text-ink border-rule hover:bg-accent-soft",
    danger: "bg-transparent text-alert border-alert hover:bg-alert/10",
  }[variant];
  return (
    <button {...r} className={`inline-flex min-h-9 items-center justify-center gap-2 rounded-reg border px-3.5 text-sm font-semibold transition disabled:cursor-not-allowed disabled:opacity-50 ${v} ${className}`}>
      {children}
    </button>
  );
}

export function Card({ title, eyebrow, actions, children, className = "", flush = false, plain = false }: { title?: string; eyebrow?: string; actions?: ReactNode; children: ReactNode; className?: string; flush?: boolean; plain?: boolean }) {
  return (
    <section className={`rounded-reg border border-rule bg-raised shadow-[var(--shadow)] ${plain ? "" : "border-t-[3px] border-t-accent"} ${className}`}>
      {(title || actions) && (
        <header className="flex flex-wrap items-center justify-between gap-2 px-4 pt-3.5 pb-1">
          <div>
            {eyebrow && <div className="eyebrow">{eyebrow}</div>}
            {title && <h3 className="text-lg">{title}</h3>}
          </div>
          {actions}
        </header>
      )}
      <div className={flush ? "" : "p-4"}>{children}</div>
    </section>
  );
}

export function StatTile({ label, value, sub, tone }: { label: string; value: string; sub?: string; tone?: "alert" }) {
  return (
    <div className="rounded-reg border border-rule border-t-[3px] border-t-accent bg-raised p-4 shadow-[var(--shadow)]">
      <div className="eyebrow">{label}</div>
      <div className={`mono mt-1 text-[28px] font-medium leading-tight ${tone === "alert" ? "text-alert" : ""}`}>{value}</div>
      {sub && <div className="mt-0.5 text-sm text-mute">{sub}</div>}
    </div>
  );
}

const statusMeta: Record<Status, { label: string; cls: string }> = {
  P: { label: "Present", cls: "text-forest border-forest bg-forest-soft" },
  L: { label: "Late", cls: "text-brass border-brass bg-brass-soft" },
  A: { label: "Absent", cls: "text-alert border-alert bg-alert/10" },
  E: { label: "Excused", cls: "text-mute border-mute bg-mute/10" },
};
export function StatusChip({ s, compact }: { s: Status; compact?: boolean }) {
  const m = statusMeta[s];
  return (
    <span className={`mono inline-flex items-center gap-1.5 rounded-full border px-2 py-0.5 text-xs font-semibold ${m.cls}`}>
      {s}
      {!compact && <span className="font-sans font-medium">{m.label}</span>}
    </span>
  );
}

export function Tag({ children, tone = "mute" }: { children: ReactNode; tone?: "mute" | "forest" | "brass" | "alert" | "accent" }) {
  const c = { mute: "text-mute border-mute", forest: "text-forest border-forest", brass: "text-brass border-brass", alert: "text-alert border-alert", accent: "text-accent border-accent" }[tone];
  return <span className={`mono inline-block whitespace-nowrap rounded-full border px-2 py-0.5 text-[11px] font-medium uppercase tracking-wide ${c}`}>{children}</span>;
}
export const invTone = (s: string) => (s === "Paid" || s === "Matched" ? "forest" : s === "Overdue" || s === "Unmatched" ? "alert" : s === "Partial" || s === "Pending" || s === "Unpaid" ? "brass" : "mute") as "forest" | "alert" | "brass" | "mute";

export function AttToggle({ value, onChange, disabled }: { value?: Status; onChange: (s: Status) => void; disabled?: boolean }) {
  return (
    <div role="radiogroup" className="inline-flex gap-1">
      {(["P", "L", "A", "E"] as Status[]).map((s) => {
        const on = value === s;
        return (
          <button
            key={s}
            role="radio"
            aria-checked={on}
            aria-label={statusMeta[s].label}
            disabled={disabled}
            onClick={() => onChange(s)}
            className={`mono h-11 w-11 rounded-reg border text-sm font-semibold transition disabled:cursor-not-allowed disabled:opacity-60 md:h-9 md:w-9 ${on ? statusMeta[s].cls + " ring-1 ring-current" : "border-rule bg-transparent text-mute hover:bg-accent-soft"}`}
          >
            {s}
          </button>
        );
      })}
    </div>
  );
}

export type Col<T> = { key: string; label: string; render?: (r: T) => ReactNode; align?: "right" | "center"; mono?: boolean; className?: string };
export function DataTable<T extends object>({ cols, rows, onRow, caption }: { cols: Col<T>[]; rows: T[]; onRow?: (r: T) => void; caption?: string }) {
  return (
    <div className="max-h-[70vh] overflow-auto">
      <table className="w-full border-collapse text-left text-sm">
        {caption && <caption className="sr-only">{caption}</caption>}
        <thead>
          <tr>
            {cols.map((c) => (
              <th key={c.key} scope="col" className={`eyebrow sticky top-0 z-10 whitespace-nowrap border-b border-rule bg-raised px-3 py-2.5 font-medium ${c.align === "right" ? "text-right" : c.align === "center" ? "text-center" : ""}`}>
                {c.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((r, i) => (
            <tr key={(r as { id?: string }).id ?? i} onClick={onRow ? () => onRow(r) : undefined} className={`border-b border-rule/70 last:border-0 hover:bg-accent-soft ${onRow ? "cursor-pointer" : ""}`}>
              {cols.map((c) => (
                <td key={c.key} className={`px-3 py-2.5 align-middle ${c.mono ? "mono" : ""} ${c.align === "right" ? "text-right" : c.align === "center" ? "text-center" : ""} ${c.className ?? ""}`}>
                  {c.render ? c.render(r) : String((r as Record<string, unknown>)[c.key] ?? "")}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export function Field({ label, children, className = "" }: { label: string; children: ReactNode; className?: string }) {
  return (
    <label className={`block ${className}`}>
      <span className="eyebrow mb-1 block">{label}</span>
      {children}
    </label>
  );
}
export const inputCls = "min-h-10 w-full rounded-reg border border-rule bg-paper px-3 text-[15px] placeholder:text-mute focus:border-accent";

export function Tabs({ tabs, value, onChange }: { tabs: string[]; value: string; onChange: (t: string) => void }) {
  return (
    <div role="tablist" className="mb-4 flex gap-1 overflow-x-auto border-b border-rule">
      {tabs.map((t) => (
        <button key={t} role="tab" aria-selected={t === value} onClick={() => onChange(t)} className={`-mb-px whitespace-nowrap border-b-2 px-3.5 py-2 text-sm font-semibold ${t === value ? "border-accent text-accent" : "border-transparent text-mute hover:text-ink"}`}>
          {t}
        </button>
      ))}
    </div>
  );
}

export function Avatar({ name }: { name: string }) {
  const i = name.split(" ").map((w) => w[0]).slice(0, 2).join("");
  return <span className="mono grid h-8 w-8 shrink-0 place-items-center rounded-full border border-rule bg-accent-soft text-xs font-semibold text-accent">{i}</span>;
}

export function LineChart({ series, labels, height = 180, suffix = "%" }: { series: { name: string; data: number[]; dash?: boolean }[]; labels: string[]; height?: number; suffix?: string }) {
  const W = 600, H = height, pad = 28;
  const all = series.flatMap((s) => s.data);
  const min = Math.floor(Math.min(...all) - 2), max = Math.ceil(Math.max(...all) + 1);
  const x = (i: number) => pad + (i * (W - pad * 1.5)) / (labels.length - 1);
  const y = (v: number) => H - pad - ((v - min) / (max - min)) * (H - pad * 1.6);
  return (
    <div>
      <svg viewBox={`0 0 ${W} ${H}`} className="w-full" role="img" aria-label="Trend chart">
        {[min, (min + max) / 2, max].map((t) => (
          <g key={t}>
            <line x1={pad} x2={W - 8} y1={y(t)} y2={y(t)} stroke="var(--rule)" />
            <text x={0} y={y(t) + 4} fontSize="10" fill="var(--mute)" fontFamily="var(--font-mono)">{Math.round(t)}</text>
          </g>
        ))}
        {series.map((s) => (
          <g key={s.name}>
            <polyline fill="none" stroke={s.dash ? "var(--mute)" : "var(--accent)"} strokeWidth="2" strokeDasharray={s.dash ? "5 4" : undefined} points={s.data.map((v, i) => `${x(i)},${y(v)}`).join(" ")} />
            {s.data.map((v, i) => (
              <circle key={i} cx={x(i)} cy={y(v)} r="3" fill="var(--raised)" stroke={s.dash ? "var(--mute)" : "var(--accent)"} strokeWidth="1.6">
                <title>{`${s.name} ${labels[i]}: ${v}${suffix}`}</title>
              </circle>
            ))}
          </g>
        ))}
        {labels.map((l, i) => (
          <text key={l} x={x(i)} y={H - 6} fontSize="10" textAnchor="middle" fill="var(--mute)" fontFamily="var(--font-mono)">{l}</text>
        ))}
      </svg>
      <div className="mt-1 flex gap-4 text-xs text-mute">
        {series.map((s) => (
          <span key={s.name} className="flex items-center gap-1.5">
            <i className={`inline-block h-0.5 w-4 ${s.dash ? "bg-mute" : "bg-accent"}`} />
            {s.name}
          </span>
        ))}
      </div>
    </div>
  );
}

/* ---------- screen wrapper with required states ---------- */
type SS = "live" | "loading" | "empty" | "error" | "locked" | "offline";
export function Screen({ eyebrow, title, actions, narrow, withOffline, emptyText = "Nothing to show yet.", children }: { eyebrow?: string; title: string; actions?: ReactNode; narrow?: boolean; withOffline?: boolean; emptyText?: string; children: (s: { locked: boolean; offline: boolean }) => ReactNode }) {
  const [st, setSt] = useState<SS>("live");
  const opts: SS[] = withOffline ? ["live", "loading", "empty", "error", "locked", "offline"] : ["live", "loading", "empty", "error", "locked"];
  return (
    <div className={`mx-auto w-full ${narrow ? "max-w-[880px]" : ""}`}>
      <div className="mb-5 flex flex-wrap items-end justify-between gap-3">
        <div>
          {eyebrow && <div className="eyebrow mb-1">{eyebrow}</div>}
          <h1 className="text-[28px] md:text-[32px]">{title}</h1>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          {actions}
          <label className="flex items-center gap-1.5" title="Preview the required screen states">
            <span className="eyebrow">State</span>
            <select value={st} onChange={(e) => setSt(e.target.value as SS)} className="mono min-h-9 rounded-reg border border-rule bg-raised px-2 text-xs">
              {opts.map((o) => (
                <option key={o}>{o}</option>
              ))}
            </select>
          </label>
        </div>
      </div>
      {st === "loading" ? (
        <div aria-busy="true" aria-label="Loading" className="rounded-reg border border-rule border-t-[3px] border-t-accent bg-raised p-4">
          {[70, 100, 100, 85, 100, 60].map((w, i) => (
            <div key={i} className="skeleton mb-3 h-4" style={{ width: w + "%" }} />
          ))}
        </div>
      ) : st === "empty" ? (
        <div className="rounded-reg border border-dashed border-rule p-10 text-center text-mute">{emptyText}</div>
      ) : st === "error" ? (
        <div role="alert" className="rounded-reg border border-alert bg-alert/10 p-5">
          <div className="font-semibold text-alert">We could not load this page.</div>
          <p className="mb-3 text-sm text-soft">The server did not respond (error 503). Your changes are safe.</p>
          <Btn variant="ghost" onClick={() => setSt("live")}>Retry</Btn>
        </div>
      ) : (
        <>
          {st === "locked" && <Banner tone="brass">Term 1 is closed. This page is read-only and changes are disabled.</Banner>}
          {st === "offline" && <Banner tone="alert">You are offline. Changes are saved on this device and will sync when you reconnect. 3 changes queued.</Banner>}
          {children({ locked: st === "locked", offline: st === "offline" })}
        </>
      )}
    </div>
  );
}
export function Banner({ tone, children }: { tone: "brass" | "alert" | "forest"; children: ReactNode }) {
  const c = { brass: "border-brass bg-brass-soft text-ink", alert: "border-alert bg-alert/10 text-ink", forest: "border-forest bg-forest-soft text-ink" }[tone];
  return (
    <div role="status" className={`mb-4 rounded-reg border-l-[3px] border px-3.5 py-2.5 text-sm ${c}`}>
      {children}
    </div>
  );
}

/* ---------- message thread ---------- */
export function MessageThread({ t, me }: { t: { student: string; section: string; teacher: string; guardian: string; msgs: { from: string; text: string; time: string; file?: string }[] }; me?: string }) {
  return (
    <div>
      <div className="mb-3 border-b border-rule pb-3">
        <div className="eyebrow">About this student</div>
        <div className="font-serif text-xl font-semibold">
          {t.student} <span className="mono text-sm font-normal text-mute">{t.section}</span>
        </div>
        <div className="text-sm text-mute">{t.guardian} and {t.teacher}</div>
      </div>
      <div className="space-y-3">
        {t.msgs.map((m, i) => {
          const mine = m.from === me;
          return (
            <div key={i} className={`flex ${mine ? "justify-end" : ""}`}>
              <div className={`max-w-[85%] rounded-reg border px-3 py-2 ${mine ? "border-accent bg-accent-soft" : "border-rule bg-paper"}`}>
                <div className="eyebrow mb-0.5">{m.from} · {m.time}</div>
                <p>{m.text}</p>
                {m.file && (
                  <span className="mono mt-1 inline-flex items-center gap-1 text-xs text-accent">
                    <Icon n="clip" size={13} />
                    {m.file}
                  </span>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

/* ---------- shell ---------- */
const NAV: Record<Role, { to: string; label: string; icon: string }[]> = {
  admin: [
    { to: "/admin", label: "Overview", icon: "home" },
    { to: "/admin/students", label: "Students", icon: "users" },
    { to: "/admin/enrollment", label: "Enrollment", icon: "pen" },
    { to: "/admin/sections", label: "Sections", icon: "grid" },
    { to: "/admin/staff", label: "Staff", icon: "users" },
    { to: "/admin/timetable", label: "Timetable", icon: "cal" },
    { to: "/admin/attendance", label: "Attendance", icon: "check" },
    { to: "/admin/fees", label: "Fees", icon: "coin" },
    { to: "/admin/payments", label: "Payments", icon: "list" },
    { to: "/admin/announcements", label: "Announcements", icon: "mega" },
    { to: "/admin/messages", label: "Messages", icon: "mail" },
    { to: "/admin/conferences", label: "Conferences", icon: "cal" },
    { to: "/admin/analytics", label: "Analytics", icon: "chart" },
    { to: "/admin/audit", label: "Audit log", icon: "shield" },
  ],
  teacher: [
    { to: "/teacher", label: "Today", icon: "home" },
    { to: "/teacher/attendance/6A/p5", label: "Attendance", icon: "check" },
    { to: "/teacher/class/6A", label: "Class", icon: "users" },
    { to: "/teacher/gradebook", label: "Gradebook", icon: "grid" },
    { to: "/teacher/comments", label: "Report comments", icon: "pen" },
    { to: "/teacher/homework", label: "Homework", icon: "book" },
    { to: "/teacher/messages", label: "Messages", icon: "mail" },
    { to: "/teacher/conferences", label: "Conferences", icon: "cal" },
  ],
  parent: [
    { to: "/parent", label: "Home", icon: "home" },
    { to: "/parent/attendance", label: "Attendance", icon: "check" },
    { to: "/parent/grades", label: "Grades", icon: "chart" },
    { to: "/parent/reports", label: "Reports", icon: "file" },
    { to: "/parent/homework", label: "Homework", icon: "book" },
    { to: "/parent/fees", label: "Fees", icon: "coin" },
    { to: "/parent/messages", label: "Messages", icon: "mail" },
    { to: "/parent/announcements", label: "Notices", icon: "mega" },
    { to: "/parent/conference", label: "Conference", icon: "cal" },
  ],
};
export const USERS: Record<Role, { name: string; title: string }> = {
  admin: { name: "Esi Mensah", title: "Registrar" },
  teacher: { name: "Kwame Boateng", title: "Teacher, 6A" },
  parent: { name: "Akua Asante", title: "Guardian" },
};
export const HOME: Record<Role, string> = { admin: "/admin", teacher: "/teacher", parent: "/parent" };

export function Shell({ role, path, children }: { role: Role; path: string; children: ReactNode }) {
  const { theme, setTheme } = useApp();
  const nav = NAV[role];
  const active = (to: string) => (to === HOME[role] ? path === to : path.startsWith(to.split("/").slice(0, 3).join("/")));
  const u = USERS[role];
  return (
    <div data-portal={role} className="min-h-screen bg-paper pb-16 md:flex md:pb-0">
      <nav aria-label="Primary" className="fixed inset-x-0 bottom-0 z-30 flex overflow-x-auto border-t border-rule bg-raised md:sticky md:top-0 md:h-screen md:w-16 md:shrink-0 md:flex-col md:overflow-y-auto md:overflow-x-hidden md:border-t-0 md:border-r lg:w-56">
        <div className="hidden border-b border-t-[3px] border-rule border-t-accent px-3 py-4 md:block">
          <div className="font-serif text-lg font-semibold leading-none lg:text-xl">
            <span className="lg:hidden">H</span>
            <span className="hidden lg:inline">Homeroom</span>
          </div>
          <div className="eyebrow mt-1.5 hidden lg:block">{role} portal</div>
        </div>
        <ul className="flex md:block md:py-2">
          {nav.map((n) => (
            <li key={n.to + n.label} className="shrink-0">
              <Link to={n.to} title={n.label} aria-current={active(n.to) ? "page" : undefined} className={`flex h-14 min-w-[68px] flex-col items-center justify-center gap-0.5 px-2 text-[11px] font-semibold md:h-10 md:min-w-0 md:flex-row md:justify-center md:gap-3 md:border-l-[3px] md:px-0 md:text-sm lg:justify-start lg:px-4 ${active(n.to) ? "border-accent bg-accent-soft text-accent" : "border-transparent text-soft hover:bg-accent-soft"}`}>
                <Icon n={n.icon} />
                <span className="md:hidden lg:inline">{n.label}</span>
              </Link>
            </li>
          ))}
        </ul>
      </nav>
      <div className="min-w-0 flex-1">
        <header className="sticky top-0 z-20 flex items-center gap-2 border-b border-rule bg-raised px-3 py-2 md:gap-3 md:px-6">
          <div className="min-w-0">
            <div className="truncate font-serif text-base font-semibold md:text-lg">{school.name}</div>
            <div className="eyebrow hidden sm:block">{school.city} · {school.term}</div>
          </div>
          <div className="relative ml-auto hidden max-w-xs flex-1 lg:block">
            <span className="absolute top-2.5 left-2.5 text-mute"><Icon n="search" size={16} /></span>
            <input aria-label="Search" placeholder="Search students, staff, invoices" className={inputCls + " pl-8"} />
          </div>
          <div className="ml-auto flex items-center gap-1 lg:ml-0">
            <label className="hidden sm:block">
              <span className="sr-only">Switch role</span>
              <select value={role} onChange={(e) => go(HOME[e.target.value as Role])} className="mono min-h-9 rounded-reg border border-rule bg-paper px-2 text-xs">
                <option value="admin">Admin</option>
                <option value="teacher">Teacher</option>
                <option value="parent">Parent</option>
              </select>
            </label>
            <Link to="/notifications" aria-label="Notifications" className="relative grid h-10 w-10 place-items-center rounded-reg hover:bg-accent-soft">
              <Icon n="bell" />
              <span className="absolute top-2 right-2 h-2 w-2 rounded-full bg-alert" />
            </Link>
            <button aria-label="Toggle theme" onClick={() => setTheme(theme === "light" ? "dark" : "light")} className="grid h-10 w-10 place-items-center rounded-reg hover:bg-accent-soft">
              <Icon n={theme === "light" ? "moon" : "sun"} />
            </button>
            <Link to="/settings" className="flex items-center gap-2 rounded-reg px-1.5 py-1 hover:bg-accent-soft">
              <Avatar name={u.name} />
              <span className="hidden text-left leading-tight lg:block">
                <span className="block text-sm font-semibold">{u.name}</span>
                <span className="eyebrow block">{u.title}</span>
              </span>
            </Link>
          </div>
        </header>
        <main className="p-4 md:p-6 lg:p-8">{children}</main>
      </div>
    </div>
  );
}
