import { useEffect, useMemo, useState } from "react";
import { QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "./api/client";
import { HOME, useSession, type Role } from "./auth/auth";
import { startOutboxSync, outbox } from "./offline/queue";
import AdminPages from "./admin";
import ParentPages from "./parent";
import TeacherPages from "./teacher";
import { CreateSchool, Forgot, Picker, Reset, SignIn, type Pending } from "./pages/auth";
import { Notifications, SandboxCheckout, Settings } from "./pages/common";
import { AppCtx, Banner, Link, Shell, go, usePath } from "./ui";

const THEME_KEY = "homeroom.theme";
const PUBLIC = new Set(["signin", "picker", "forgot", "reset", "onboard"]);

function initialTheme(): "light" | "dark" {
  try {
    const saved = localStorage.getItem(THEME_KEY);
    if (saved === "light" || saved === "dark") return saved;
  } catch {
    /* storage blocked */
  }
  return window.matchMedia?.("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

function Routes({ pending, onPending }: { pending: Pending | null; onPending: (p: Pending) => void }) {
  const fullPath = usePath();
  const [path, search = ""] = fullPath.split("?");
  const query = new URLSearchParams(search);
  const { me, role: sessionRole } = useSession();
  const [theme, setThemeState] = useState<"light" | "dark">(initialTheme);
  const [child, setChild] = useState<string>("");
  const [msg, setMsg] = useState<string | null>(null);

  const setTheme = (t: "light" | "dark") => {
    setThemeState(t);
    try {
      localStorage.setItem(THEME_KEY, t);
    } catch {
      /* storage blocked: the choice lasts for this tab */
    }
  };
  useEffect(() => { document.documentElement.dataset.theme = theme; }, [theme]);
  useEffect(() => {
    if (!msg) return;
    const t = setTimeout(() => setMsg(null), 3200);
    return () => clearTimeout(t);
  }, [msg]);

  // A parent's chosen child: default to the first, and keep it valid if the list changes.
  const childIds = (me?.children ?? []).map((c) => c.id).join(",");
  useEffect(() => {
    const ids = childIds ? childIds.split(",") : [];
    if (ids.length && !ids.includes(child)) setChild(ids[0]!);
  }, [childIds, child]);

  // Tell people when writes they made offline were refused after all (for example a term closed meanwhile).
  useEffect(
    () =>
      outbox.subscribe(() => {
        const d = outbox.takeDropped();
        if (d.length) setMsg(`${d.length} saved change${d.length === 1 ? " was" : "s were"} not accepted: ${d[0]!.label}. ${d[0]!.reason}`);
      }),
    [],
  );

  const seg = path.split("/")[1] ?? "";
  const signedOutOk = PUBLIC.has(seg);

  // Route guards: signed-out people go to sign-in; signed-in people never see it; each portal is for its own role.
  useEffect(() => {
    if (!sessionRole && !signedOutOk) go("/signin");
    else if (sessionRole && (seg === "signin" || seg === "picker" || seg === "")) go(HOME[sessionRole]);
    else if (sessionRole && (seg === "admin" || seg === "teacher" || seg === "parent") && seg !== sessionRole) go(HOME[sessionRole]);
  }, [sessionRole, seg, signedOutOk]);

  const ctx = useMemo(
    () => ({ theme, setTheme, toast: setMsg, role: (sessionRole ?? "admin") as Role, child, setChild }),
    [theme, sessionRole, child],
  );

  let body;
  if (!sessionRole) {
    body =
      seg === "picker" ? <Picker pending={pending} />
      : seg === "forgot" ? <Forgot />
      : seg === "reset" ? <Reset token={query.get("token") ?? ""} />
      : seg === "onboard" ? <CreateSchool />
      : <SignIn onPending={onPending} />;
  } else {
    const role = sessionRole;
    const page =
      seg === "admin" ? <AdminPages path={path} />
      : seg === "teacher" ? <TeacherPages path={path} />
      : seg === "parent" ? (path.startsWith("/parent/pay/sandbox") ? <SandboxCheckout reference={query.get("ref") ?? ""} /> : <ParentPages path={path} />)
      : seg === "notifications" ? <Notifications />
      : seg === "settings" ? <Settings />
      : <Banner tone="alert">Page not found. <Link to={HOME[role]} className="underline">Go home</Link></Banner>;
    body = <Shell role={role} path={path}><div key={path}>{page}</div></Shell>;
  }

  return (
    <AppCtx.Provider value={ctx}>
      {body}
      {msg && <div role="status" className="fixed right-4 bottom-20 z-50 max-w-sm rounded-reg border border-rule border-l-[3px] border-l-forest bg-raised px-4 py-2.5 text-sm shadow-lg md:bottom-6">{msg}</div>}
    </AppCtx.Provider>
  );
}

export default function App() {
  const [pending, setPending] = useState<Pending | null>(null);
  // Keep trying to deliver anything saved while offline, for as long as the app is open.
  useEffect(() => startOutboxSync(), []);
  return (
    <QueryClientProvider client={queryClient}>
      <Routes pending={pending} onPending={setPending} />
    </QueryClientProvider>
  );
}
