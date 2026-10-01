import { useState, type FormEvent } from "react";
import { api } from "../api/client";
import { errorMessage } from "../api/errors";
import { HOME, choosePerson, requestOtp, signInWithOtp, signInWithPassword, type Choice, type Role, type SignInOutcome } from "../auth/auth";
import { Banner, Btn, Field, Link, go, inputCls } from "../ui";

/** Choices waiting for the person to pick a role after an account with several roles signed in. */
export interface Pending {
  token: string;
  choices: Choice[];
}

const DEMO = import.meta.env.DEV || import.meta.env.VITE_DEMO === "true";
const DEMO_EMAIL: Record<Role, string> = {
  admin: "esi.mensah@greenfield.edu.gh",
  teacher: "kwame.boateng@greenfield.edu.gh",
  parent: "akua.asante@greenfield.edu.gh",
};
const DEMO_PHONE = "024 000 0001";

const ROLE_LABEL: Record<Choice["role"], string> = { admin: "Admin / Registrar", teacher: "Teacher", guardian: "Parent / guardian", student: "Student" };
const PORTAL: Record<Choice["role"], Role> = { admin: "admin", teacher: "teacher", guardian: "parent", student: "parent" };

export function SignIn({ onPending }: { onPending: (p: Pending) => void }) {
  const [demoRole, setDemoRole] = useState<Role>("admin");
  const [email, setEmail] = useState(DEMO ? DEMO_EMAIL.admin : "");
  const [password, setPassword] = useState(DEMO ? "password123" : "");
  const [sms, setSms] = useState(false);
  const [phone, setPhone] = useState(DEMO ? DEMO_PHONE : "");
  const [codeSent, setCodeSent] = useState(false);
  const [code, setCode] = useState("");
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  const finish = (o: SignInOutcome) => {
    setBusy(false);
    if (o.kind === "signed-in") go(HOME[o.role]);
    else if (o.kind === "choose") {
      onPending({ token: o.token, choices: o.choices });
      go("/picker");
    } else setMessage(o.message);
  };

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setMessage(null);
    if (!sms) return finish(await signInWithPassword(email.trim(), password));
    if (!codeSent) {
      const r = await requestOtp(phone);
      setBusy(false);
      if (r.ok) setCodeSent(true);
      else setMessage(r.message);
      return;
    }
    finish(await signInWithOtp(phone, code.trim()));
  };

  const pickDemo = (r: Role) => {
    setDemoRole(r);
    setEmail(DEMO_EMAIL[r]);
    setSms(false);
  };

  return (
    <div data-portal={demoRole} className="grid min-h-screen bg-paper md:grid-cols-[1fr_1fr]">
      <div className="hidden flex-col justify-between border-r border-rule bg-raised p-10 md:flex">
        <div className="eyebrow">Greenfield Academy</div>
        <div>
          <h1 className="text-5xl leading-[1.05]">Homeroom</h1>
          <p className="mt-4 max-w-sm text-lg text-soft">The register, the gradebook and the fee book, kept in one place.</p>
        </div>
        <div className="mono text-xs text-mute">Attendance · Grades · Fees · Messages</div>
      </div>
      <div className="flex items-center justify-center p-6">
        <form className="w-full max-w-sm" onSubmit={submit}>
          <h2 className="mb-1 text-3xl md:hidden">Homeroom</h2>
          <h2 className="mb-1 text-2xl">Sign in</h2>
          <p className="mb-5 text-sm text-mute">{sms ? "We will text you a code." : "Use the email your school registered."}</p>
          {message && <Banner tone="alert">{message}</Banner>}
          {DEMO && (
            <div className="mb-4 grid grid-cols-3 gap-1" role="radiogroup" aria-label="Demo role">
              {(["admin", "teacher", "parent"] as Role[]).map((r) => (
                <button type="button" key={r} role="radio" aria-checked={demoRole === r} onClick={() => pickDemo(r)} className={`mono min-h-10 rounded-reg border text-xs font-semibold capitalize ${demoRole === r ? "border-accent bg-accent text-on-accent" : "border-rule"}`}>
                  {r}
                </button>
              ))}
            </div>
          )}
          <div className="space-y-4">
            <div className="flex gap-4 text-sm">
              <label className="flex gap-1.5"><input type="radio" checked={!sms} onChange={() => { setSms(false); setCodeSent(false); }} className="accent-[var(--accent)]" />Email</label>
              <label className="flex gap-1.5"><input type="radio" checked={sms} onChange={() => setSms(true)} className="accent-[var(--accent)]" />SMS code</label>
            </div>
            {sms ? (
              <>
                <Field label="Mobile number"><input className={inputCls + " mono"} inputMode="tel" autoComplete="tel" value={phone} onChange={(e) => { setPhone(e.target.value); setCodeSent(false); }} /></Field>
                {codeSent && <Field label="6-digit code"><input className={inputCls + " mono"} inputMode="numeric" autoComplete="one-time-code" maxLength={6} value={code} onChange={(e) => setCode(e.target.value)} autoFocus /></Field>}
              </>
            ) : (
              <>
                <Field label="Email"><input className={inputCls} type="email" autoComplete="username" value={email} onChange={(e) => setEmail(e.target.value)} /></Field>
                <Field label="Password"><input className={inputCls} type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} /></Field>
              </>
            )}
            <Btn type="submit" className="w-full" disabled={busy}>{busy ? "Please wait…" : sms ? (codeSent ? "Sign in" : "Send code") : "Sign in"}</Btn>
            {!sms && <Link to="/forgot" className="block text-sm font-semibold text-accent">Forgot password</Link>}
            <Link to="/onboard" className="block text-sm font-semibold text-accent">New school? Create one</Link>
          </div>
        </form>
      </div>
    </div>
  );
}

export function Picker({ pending }: { pending: Pending | null }) {
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  if (!pending) {
    go("/signin");
    return null;
  }
  const pick = async (personId: string) => {
    setBusy(true);
    const o = await choosePerson(pending.token, personId);
    setBusy(false);
    if (o.kind === "signed-in") go(HOME[o.role]);
    else if (o.kind === "failed") {
      setMessage("That took too long. Please sign in again.");
      setTimeout(() => go("/signin"), 1500);
    }
  };
  return (
    <div data-portal="admin" className="flex min-h-screen items-center justify-center bg-paper p-6">
      <div className="w-full max-w-md">
        <div className="eyebrow mb-1">{pending.choices[0]?.full_name} holds more than one role</div>
        <h1 className="mb-4 text-3xl">Continue as</h1>
        {message && <Banner tone="alert">{message}</Banner>}
        <div className="space-y-3">
          {pending.choices.map((c) => (
            <button key={c.person_id} disabled={busy} data-portal={PORTAL[c.role]} onClick={() => void pick(c.person_id)} className="block w-full rounded-reg border border-rule border-t-[3px] border-t-accent bg-raised p-4 text-left hover:bg-accent-soft disabled:opacity-60">
              <div className="font-serif text-xl font-semibold">{ROLE_LABEL[c.role]}</div>
              <div className="text-sm text-mute">{c.school_name}</div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

export function Forgot() {
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    try {
      const { error } = await api.POST("/auth/password/forgot", { body: { email: email.trim() } });
      if (error) setMessage(errorMessage(error));
      else setSent(true);
    } catch (err) {
      setMessage(errorMessage(err));
    }
    setBusy(false);
  };
  return (
    <div data-portal="admin" className="flex min-h-screen items-center justify-center bg-paper p-6">
      <form onSubmit={submit} className="w-full max-w-sm">
        <h1 className="mb-1 text-3xl">Reset password</h1>
        {sent ? (
          <>
            <p className="my-4 text-soft">If that address has an account, we have emailed a link to choose a new password. It works for one hour.</p>
            <Link to="/signin" className="font-semibold text-accent">Back to sign in</Link>
          </>
        ) : (
          <div className="mt-4 space-y-4">
            {message && <Banner tone="alert">{message}</Banner>}
            <Field label="Email"><input className={inputCls} type="email" autoComplete="username" required value={email} onChange={(e) => setEmail(e.target.value)} /></Field>
            <Btn type="submit" className="w-full" disabled={busy || !email}>{busy ? "Sending…" : "Email me a link"}</Btn>
            <Link to="/signin" className="block text-sm font-semibold text-accent">Back to sign in</Link>
          </div>
        )}
      </form>
    </div>
  );
}

export function CreateSchool() {
  const [inviteCode, setInviteCode] = useState("");
  const [schoolName, setSchoolName] = useState("");
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [done, setDone] = useState(false);
  const valid = inviteCode.trim() && schoolName.trim() && fullName.trim() && email.trim();

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setMessage(null);
    try {
      const { error } = await api.POST("/schools", {
        body: { invite_code: inviteCode.trim(), school_name: schoolName.trim(), admin: { full_name: fullName.trim(), email: email.trim() } },
      });
      if (error) setMessage(errorMessage(error));
      else setDone(true);
    } catch (err) {
      setMessage(errorMessage(err));
    }
    setBusy(false);
  };

  return (
    <div data-portal="admin" className="flex min-h-screen items-center justify-center bg-paper p-6">
      <form onSubmit={submit} className="w-full max-w-sm">
        <h1 className="mb-1 text-3xl">Create your school</h1>
        {done ? (
          <>
            <p className="my-4 text-soft">{schoolName} is set up. We have emailed {email} a link to choose a password.</p>
            <Btn onClick={() => go("/signin")}>Back to sign in</Btn>
          </>
        ) : (
          <div className="mt-4 space-y-4">
            <p className="text-sm text-mute">You will need the invite code your school was given.</p>
            {message && <Banner tone="alert">{message}</Banner>}
            <Field label="Invite code"><input className={inputCls + " mono"} autoComplete="off" value={inviteCode} onChange={(e) => setInviteCode(e.target.value)} /></Field>
            <Field label="School name"><input className={inputCls} value={schoolName} onChange={(e) => setSchoolName(e.target.value)} /></Field>
            <Field label="Your name"><input className={inputCls} autoComplete="name" value={fullName} onChange={(e) => setFullName(e.target.value)} /></Field>
            <Field label="Your email"><input className={inputCls} type="email" autoComplete="username" value={email} onChange={(e) => setEmail(e.target.value)} /></Field>
            <Btn type="submit" className="w-full" disabled={busy || !valid}>{busy ? "Creating…" : "Create school"}</Btn>
            <Link to="/signin" className="block text-sm font-semibold text-accent">Back to sign in</Link>
          </div>
        )}
      </form>
    </div>
  );
}

export function Reset({ token }: { token: string }) {
  const [pw, setPw] = useState("");
  const [again, setAgain] = useState("");
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [done, setDone] = useState(false);
  const valid = pw.length >= 8 && pw === again;
  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    try {
      const { error } = await api.POST("/auth/password/reset", { body: { token, new_password: pw } });
      if (error) setMessage(errorMessage(error));
      else setDone(true);
    } catch (err) {
      setMessage(errorMessage(err));
    }
    setBusy(false);
  };
  return (
    <div data-portal="admin" className="flex min-h-screen items-center justify-center bg-paper p-6">
      <form onSubmit={submit} className="w-full max-w-sm">
        <h1 className="mb-1 text-3xl">Choose a password</h1>
        {done ? (
          <>
            <p className="my-4 text-soft">Your password is set. You have been signed out everywhere else.</p>
            <Btn onClick={() => go("/signin")}>Sign in</Btn>
          </>
        ) : (
          <div className="mt-4 space-y-4">
            {message && <Banner tone="alert">{message}</Banner>}
            <Field label="New password"><input className={inputCls} type="password" autoComplete="new-password" value={pw} onChange={(e) => setPw(e.target.value)} /></Field>
            <Field label="Repeat it"><input className={inputCls} type="password" autoComplete="new-password" value={again} onChange={(e) => setAgain(e.target.value)} /></Field>
            <p className={`text-sm ${pw && !valid ? "text-alert" : "text-mute"}`}>At least 8 characters, typed the same twice.</p>
            <Btn type="submit" className="w-full" disabled={busy || !valid}>{busy ? "Saving…" : "Set password"}</Btn>
          </div>
        )}
      </form>
    </div>
  );
}
