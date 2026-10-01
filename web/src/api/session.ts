import type { components } from "./schema";

/**
 * The signed-in session, kept in memory and mirrored to localStorage so a reload keeps you signed in.
 *
 * Two rules matter for unreliable networks:
 *  - Access tokens are refreshed shortly BEFORE they expire, so most requests never see a 401.
 *  - A refresh that fails because the network is down never signs the user out; only the server saying
 *    "that refresh token is no longer valid" does. A teacher on a flaky connection keeps their session.
 */

export type Me = components["schemas"]["Me"];
type SessionBody = components["schemas"]["Session"];

export interface StoredSession {
  accessToken: string;
  refreshToken: string;
  /** Epoch ms when the access token stops being valid. */
  expiresAt: number;
  /** Server time minus device time when the session was last refreshed, so "today" follows the server, not a wrong device clock. */
  clockOffsetMs?: number;
  me: Me;
}

const KEY = "homeroom.session.v1";
/** Refresh this long before expiry. */
const EARLY_MS = 30_000;

function read(): StoredSession | null {
  try {
    const raw = localStorage.getItem(KEY);
    return raw ? (JSON.parse(raw) as StoredSession) : null;
  } catch {
    return null; // private mode, blocked storage, or corrupt data: start signed out
  }
}

function write(s: StoredSession | null) {
  try {
    if (s) localStorage.setItem(KEY, JSON.stringify(s));
    else localStorage.removeItem(KEY);
  } catch {
    /* storage unavailable: the in-memory session still works for this tab */
  }
}

let state: StoredSession | null = read();
let version = 0;
const listeners = new Set<() => void>();
const emit = () => {
  version++;
  listeners.forEach((l) => l());
};

let inflight: Promise<boolean> | null = null;

export const session = {
  get: (): StoredSession | null => state,
  /** Changes whenever the session does; for useSyncExternalStore. */
  snapshot: (): number => version,
  subscribe(fn: () => void): () => void {
    listeners.add(fn);
    return () => listeners.delete(fn);
  },

  /** Start a session from a successful sign-in, refresh or role selection. */
  set(body: SessionBody, now = Date.now()) {
    state = {
      accessToken: body.access_token,
      refreshToken: body.refresh_token,
      expiresAt: now + body.expires_in * 1000,
      clockOffsetMs: Date.parse(body.me.now) - now,
      me: body.me,
    };
    write(state);
    emit();
  },

  clear() {
    state = null;
    write(null);
    emit();
  },

  hasRefresh: (): boolean => !!state?.refreshToken,

  /** A valid access token, refreshing first if it is about to expire. Null if signed out. */
  async accessToken(now = Date.now()): Promise<string | null> {
    if (!state) return null;
    if (now > state.expiresAt - EARLY_MS) await session.refresh();
    return state?.accessToken ?? null;
  },

  /**
   * Exchange the refresh token. Single-flight: concurrent callers share one request (the server rotates
   * tokens, so two parallel refreshes would invalidate each other). Returns true if the session is usable.
   */
  refresh(): Promise<boolean> {
    if (!state) return Promise.resolve(false);
    inflight ??= (async () => {
      const current = state;
      if (!current) return false;
      try {
        const res = await fetch(`${API_BASE}/auth/refresh`, {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({ refresh_token: current.refreshToken }),
        });
        if (res.ok) {
          session.set((await res.json()) as SessionBody);
          return true;
        }
        if (res.status === 401) {
          session.clear(); // revoked, reused or expired: the user must sign in again
          return false;
        }
        return state !== null; // a 5xx: keep the session and try again later
      } catch {
        return state !== null; // offline: keep the session, try again when the network is back
      } finally {
        inflight = null;
      }
    })();
    return inflight;
  },
};

/** The current time as the server sees it. Use instead of `new Date()` for anything about "today". */
export const appNow = (): Date => new Date(Date.now() + (state?.clockOffsetMs ?? 0));

export const API_BASE: string = import.meta.env.VITE_API_URL ?? "/v1";
