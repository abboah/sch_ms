import { useSyncExternalStore } from "react";
import { api, queryClient } from "../api/client";
import { session, type Me } from "../api/session";
import type { components } from "../api/schema";

export type Role = "admin" | "teacher" | "parent";
export type ApiRole = components["schemas"]["Role"];
export type Choice = components["schemas"]["SelectionRequired"]["choices"][number];
type SessionBody = components["schemas"]["Session"];
type SignInBody = components["schemas"]["SignInResult"];

/** The API calls a guardian a "guardian"; the portal is the parent portal. */
export const portalOf = (r: ApiRole): Role => (r === "admin" ? "admin" : r === "teacher" ? "teacher" : "parent");
export const HOME: Record<Role, string> = { admin: "/admin", teacher: "/teacher", parent: "/parent" };

export function useSession() {
  useSyncExternalStore(session.subscribe, session.snapshot);
  const s = session.get();
  return { session: s, me: s?.me ?? null, role: s ? portalOf(s.me.role) : null };
}

/** The signed-in person; throws if called outside a signed-in screen (a programming error, not a user one). */
export function useMe(): Me {
  const { me } = useSession();
  if (!me) throw new Error("useMe() needs a signed-in user");
  return me;
}

export type SignInOutcome =
  | { kind: "signed-in"; role: Role }
  | { kind: "choose"; token: string; choices: Choice[] }
  | { kind: "failed"; message: string };

function startSession(body: SessionBody): SignInOutcome {
  session.set(body);
  queryClient.clear();
  return { kind: "signed-in", role: portalOf(body.me.role) };
}

/** Sign-in either starts a session, or asks which role to continue as. */
function outcome(body: SignInBody): SignInOutcome {
  if (body.status === "selection_required" && body.selection) return { kind: "choose", token: body.selection.selection_token, choices: body.selection.choices };
  if (body.session) return startSession(body.session);
  return { kind: "failed", message: "Sign-in failed. Please try again." };
}

const failure = (e: unknown): SignInOutcome => ({
  kind: "failed",
  message: e instanceof TypeError ? "Cannot reach the server. Check your connection and try again." : ((e as { detail?: string } | undefined)?.detail ?? "Sign-in failed. Please try again."),
});

export async function signInWithPassword(email: string, password: string): Promise<SignInOutcome> {
  try {
    const { data, error } = await api.POST("/auth/sessions", { body: { email, password } });
    return data ? outcome(data) : failure(error);
  } catch (e) {
    return failure(e);
  }
}

export async function requestOtp(phone: string): Promise<{ ok: true } | { ok: false; message: string }> {
  try {
    const { error } = await api.POST("/auth/otp", { body: { phone } });
    return error ? { ok: false, message: (error as { detail?: string }).detail ?? "Could not send a code." } : { ok: true };
  } catch (e) {
    const f = failure(e);
    return { ok: false, message: f.kind === "failed" ? f.message : "" };
  }
}

export async function signInWithOtp(phone: string, code: string): Promise<SignInOutcome> {
  try {
    const { data, error } = await api.POST("/auth/otp/verify", { body: { phone, code } });
    return data ? outcome(data) : failure(error);
  } catch (e) {
    return failure(e);
  }
}

export async function choosePerson(token: string, personId: string): Promise<SignInOutcome> {
  try {
    const { data, error } = await api.POST("/auth/sessions/select", { body: { selection_token: token, person_id: personId } });
    return data ? startSession(data) : failure(error);
  } catch (e) {
    return failure(e);
  }
}

/** Sign out here and on the server. Works offline too: local sign-out always succeeds. */
export async function signOut(): Promise<void> {
  try {
    await api.DELETE("/auth/sessions/current");
  } catch {
    /* offline: the refresh token will simply expire */
  }
  session.clear();
  queryClient.clear();
}
