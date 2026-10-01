import { createApp } from '../../src/app.ts';
import { createDeps } from '../../src/bootstrap.ts';
import { loadConfig } from '../../src/config.ts';
import { openPglite } from '../../src/db/pglite.ts';
import { seedDemo } from '../../src/dev/seed.ts';
import { consoleEmail, consolePush, consoleSms } from '../../src/integrations/channels.ts';
import { SandboxGateway } from '../../src/integrations/payments.ts';
import { fixedClock } from '../../src/lib/clock.ts';
import { createLogger } from '../../src/lib/logger.ts';
import { assertContract } from './contract.ts';
import { createHash } from 'node:crypto';

/** Deterministic ids: same as seed.sql's md5(key)::uuid. */
export function id(key: string): string {
  const h = createHash('md5').update(key).digest('hex');
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-${h.slice(12, 16)}-${h.slice(16, 20)}-${h.slice(20)}`;
}

export const PASSWORD = 'password123';
/** "Today" inside the demo school: Monday 5 October 2026, 08:00 in Accra (UTC+0). */
export const NOW = '2026-10-05T08:00:00Z';

export interface CallOptions {
  as?: string;
  json?: unknown;
  raw?: string;
  headers?: Record<string, string>;
  /** Skip contract validation (for deliberately malformed requests that hit undeclared errors). */
  noContract?: boolean;
}
export interface CallResult<T = any> {
  status: number;
  body: T;
  headers: Headers;
}

export async function setup() {
  const config = loadConfig({
    NODE_ENV: 'test',
    JWT_SECRET: 'test-secret-test-secret-test-secret-123456',
    PAYMENT_WEBHOOK_SECRET: 'test-webhook-secret-123',
    AUTH_RATE_LIMIT_PER_MINUTE: '0',
  });
  // Only real errors (5xx) are printed, so a server bug is never hidden behind a generic problem document.
  const silentLogger = createLogger({ level: 'error', sink: (line) => console.error(line.slice(0, 1500)) });
  const clock = fixedClock(NOW);
  const sms = consoleSms(silentLogger);
  const push = consolePush(silentLogger);
  const email = consoleEmail(silentLogger);
  const payments = new SandboxGateway(config.PAYMENT_WEBHOOK_SECRET, config.PUBLIC_WEB_URL);
  const db = await openPglite();
  const deps = await createDeps(config, { db, clock, log: silentLogger, sms, push, email, payments });
  await seedDemo(db, PASSWORD);
  const app = createApp(deps);

  const tokens = new Map<string, string>();

  async function call<T = any>(method: string, path: string, opts: CallOptions = {}): Promise<CallResult<T>> {
    const headers: Record<string, string> = { ...opts.headers };
    if (opts.as) headers['authorization'] = `Bearer ${opts.as}`;
    let body: string | undefined;
    if (opts.json !== undefined) {
      headers['content-type'] ??= 'application/json';
      body = JSON.stringify(opts.json);
    } else if (opts.raw !== undefined) {
      body = opts.raw;
    }
    const res = await app.request(`/v1${path}`, { method, headers, ...(body !== undefined ? { body } : {}) });
    const text = await res.text();
    const isJson = /json/.test(res.headers.get('content-type') ?? '');
    if (!isJson && text) return { status: res.status, body: text as T, headers: res.headers }; // e.g. CSV export
    const parsed = text ? JSON.parse(text) : null;
    if (res.status === 500) console.error(`
[harness] 500 from ${method} ${path}:`, JSON.stringify(parsed));
    if (!opts.noContract) await assertContract(method, `/v1${path}`, res.status, parsed);
    return { status: res.status, body: parsed as T, headers: res.headers };
  }

  /** Sign in a demo user by key (e.g. 'akua') and return their access token (cached). */
  async function login(key: DemoUser): Promise<string> {
    const cached = tokens.get(key);
    if (cached) return cached;
    const r = await call<{ session: { access_token: string } }>('POST', '/auth/sessions', {
      json: { email: EMAILS[key], password: PASSWORD },
    });
    if (r.status !== 200) throw new Error(`login ${key} failed: ${JSON.stringify(r.body)}`);
    tokens.set(key, r.body.session.access_token);
    return r.body.session.access_token;
  }

  return {
    app, deps, config, clock, sms, push, email, payments, call, login, db,
    async close() {
      await db.close();
    },
  };
}

export type Harness = Awaited<ReturnType<typeof setup>>;

export type DemoUser = 'esi' | 'kwame' | 'abena' | 'yaw' | 'comfort' | 'akua' | 'kwabena' | 'nana' | 'samuel' | 'efua';
export const EMAILS: Record<DemoUser, string> = {
  esi: 'esi.mensah@greenfield.edu.gh',
  kwame: 'kwame.boateng@greenfield.edu.gh',
  abena: 'abena.owusu@greenfield.edu.gh',
  yaw: 'yaw.darko@greenfield.edu.gh',
  comfort: 'comfort.sefa@greenfield.edu.gh',
  akua: 'akua.asante@greenfield.edu.gh',
  kwabena: 'kwabena.asante@greenfield.edu.gh',
  nana: 'nana.adjei@greenfield.edu.gh',
  samuel: 'samuel.tetteh@greenfield.edu.gh',
  efua: 'efua.quaye@greenfield.edu.gh',
};
