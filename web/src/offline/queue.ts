import { useSyncExternalStore } from "react";
import { rawWrite } from "../api/client";
import { problemOf, type Problem } from "../api/errors";

/**
 * Writes that must not be lost when the connection drops (the attendance register, scores).
 *
 * A write is attempted immediately. If the network is down, or the server answers 5xx, it is saved on
 * this device and retried until the server accepts it: when the browser says it is back online, when the
 * tab becomes visible, and every 15 seconds while anything is waiting. Every write carries an
 * Idempotency-Key, so a retry after a half-finished attempt can never apply twice.
 *
 * A 4xx answer means the server understood and refused (for example the term closed while offline).
 * Retrying cannot help, so the write is dropped and reported rather than blocking the queue forever.
 */

export interface QueuedWrite {
  id: string;
  method: "PUT" | "PATCH" | "POST";
  /** Concrete API path, ids already substituted, e.g. /class_sections/…/attendance */
  path: string;
  body: unknown;
  key: string;
  /** A sentence for people: "Register for 6A, Maths" */
  label: string;
  createdAt: number;
}

export interface Dropped {
  label: string;
  reason: string;
}

const KEY = "homeroom.outbox.v1";
const RETRY_EVERY_MS = 15_000;

function read(): QueuedWrite[] {
  try {
    const raw = localStorage.getItem(KEY);
    return raw ? (JSON.parse(raw) as QueuedWrite[]) : [];
  } catch {
    return [];
  }
}
function persist(items: QueuedWrite[]) {
  try {
    localStorage.setItem(KEY, JSON.stringify(items));
  } catch {
    /* storage full or blocked: the in-memory queue still works until the tab closes */
  }
}

let items: QueuedWrite[] = read();
let version = 0;
let dropped: Dropped[] = [];
let flushing: Promise<void> | null = null;
const listeners = new Set<() => void>();
const emit = () => {
  version++;
  listeners.forEach((l) => l());
};

const uuid = () => (typeof crypto !== "undefined" && typeof crypto.randomUUID === "function" ? crypto.randomUUID() : `${Date.now()}-${Math.random().toString(16).slice(2)}`);

/** `body` is what the server answered (for batch endpoints: the per-entry outcomes). */
export type SubmitResult = { status: "sent"; body: unknown } | { status: "queued" } | { status: "rejected"; problem: Problem | null };

async function problemFrom(res: Response): Promise<Problem | null> {
  try {
    return problemOf(await res.json());
  } catch {
    return null;
  }
}

export const outbox = {
  list: (): readonly QueuedWrite[] => items,
  count: (): number => items.length,
  snapshot: (): number => version,
  subscribe(fn: () => void): () => void {
    listeners.add(fn);
    return () => listeners.delete(fn);
  },
  /** Writes the server refused while replaying; shown once, then cleared. */
  takeDropped(): Dropped[] {
    const d = dropped;
    dropped = [];
    if (d.length) emit();
    return d;
  },

  /** Try now; if the network or server fails, keep it and retry in the background. */
  async submit(w: Omit<QueuedWrite, "id" | "createdAt" | "key"> & { key?: string }): Promise<SubmitResult> {
    const write: QueuedWrite = { ...w, id: uuid(), key: w.key ?? uuid(), createdAt: Date.now() };
    try {
      const res = await rawWrite(write.method, write.path, write.body, write.key);
      if (res.ok) return { status: "sent", body: await res.json().catch(() => null) };
      if (res.status >= 500 || res.status === 408 || res.status === 429) return enqueue(write);
      return { status: "rejected", problem: await problemFrom(res) };
    } catch {
      return enqueue(write); // fetch rejected: offline
    }
  },

  /** Replay in order. Stops at the first write that cannot be delivered yet, so order is preserved. */
  flush(): Promise<void> {
    flushing ??= (async () => {
      try {
        while (items.length) {
          const next = items[0]!;
          let res: Response;
          try {
            res = await rawWrite(next.method, next.path, next.body, next.key);
          } catch {
            return; // still offline
          }
          if (res.ok) {
            remove(next.id);
          } else if (res.status === 401 || res.status >= 500 || res.status === 408 || res.status === 429) {
            return; // signed out or server struggling: keep everything, try again later
          } else {
            const p = await problemFrom(res);
            dropped.push({ label: next.label, reason: p?.detail ?? p?.title ?? `Refused (${res.status})` });
            remove(next.id);
          }
        }
      } finally {
        flushing = null;
      }
    })();
    return flushing;
  },
};

function enqueue(w: QueuedWrite): SubmitResult {
  items = [...items, w];
  persist(items);
  emit();
  return { status: "queued" };
}
function remove(id: string) {
  items = items.filter((x) => x.id !== id);
  persist(items);
  emit();
}

/** Call once at startup. Keeps trying to deliver queued writes for as long as the app is open. */
export function startOutboxSync(): () => void {
  const tryFlush = () => {
    if (items.length) void outbox.flush();
  };
  const timer = setInterval(tryFlush, RETRY_EVERY_MS);
  const onVisible = () => document.visibilityState === "visible" && tryFlush();
  window.addEventListener("online", tryFlush);
  document.addEventListener("visibilitychange", onVisible);
  tryFlush();
  return () => {
    clearInterval(timer);
    window.removeEventListener("online", tryFlush);
    document.removeEventListener("visibilitychange", onVisible);
  };
}

export const useOutboxCount = (): number => {
  useSyncExternalStore(outbox.subscribe, outbox.snapshot);
  return outbox.count();
};

/** The browser's own idea of connectivity (a hint: it cannot see a dead server). */
export function useOnline(): boolean {
  return useSyncExternalStore(
    (cb) => {
      window.addEventListener("online", cb);
      window.addEventListener("offline", cb);
      return () => {
        window.removeEventListener("online", cb);
        window.removeEventListener("offline", cb);
      };
    },
    () => navigator.onLine,
    () => true,
  );
}
