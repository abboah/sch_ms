import { createHash, randomUUID } from 'node:crypto';
import type { MiddlewareHandler } from 'hono';
import type { AppEnv, Deps } from '../context.ts';
import { AppError, conflict, tooMany, toProblem, unauthorized, unprocessable } from './errors.ts';

const REQUEST_ID_RE = /^[A-Za-z0-9._-]{8,64}$/;

/** Assigns every request an id, returns it in `X-Request-Id`, logs start/finish with duration. */
export function requestContext(deps: Deps): MiddlewareHandler<AppEnv> {
  return async (c, next) => {
    const incoming = c.req.header('x-request-id');
    const requestId = incoming && REQUEST_ID_RE.test(incoming) ? incoming : randomUUID();
    const log = deps.log.child({ requestId });
    c.set('requestId', requestId);
    c.set('log', log);
    c.header('x-request-id', requestId);

    const started = performance.now();
    await next();
    const ms = Math.round(performance.now() - started);
    const level = c.res.status >= 500 ? 'error' : 'info';
    log[level]('request', {
      method: c.req.method,
      path: c.req.path,
      status: c.res.status,
      ms,
      person: c.var.auth?.personId,
    });
  };
}

/** One place that turns anything thrown into a problem+json response. */
export function errorHandler(): (err: Error, c: Parameters<MiddlewareHandler<AppEnv>>[0]) => Response {
  return (err, c) => {
    const requestId = c.get('requestId');
    const problem = toProblem(err, requestId);
    if (problem.status >= 500) {
      (c.get('log') ?? console).error?.('unhandled error', { err } as never);
    } else if (!(err instanceof AppError)) {
      c.get('log')?.debug('translated error', { code: problem.code, err });
    }
    return new Response(JSON.stringify(problem), {
      status: problem.status,
      headers: { 'content-type': 'application/problem+json', 'x-request-id': requestId ?? '' },
    });
  };
}

/** Requires a valid access token; puts the caller's identity on the context. */
export function authenticate(deps: Deps): MiddlewareHandler<AppEnv> {
  return async (c, next) => {
    const header = c.req.header('authorization') ?? '';
    const match = /^Bearer (.+)$/i.exec(header);
    if (!match) throw unauthorized();
    const claims = await deps.tokens.verifyAccess(match[1] as string);
    c.set('auth', claims);
    await next();
  };
}

/** Restricts a route to certain roles. The database still enforces the real rules. */
export function requireRole(...roles: string[]): MiddlewareHandler<AppEnv> {
  return async (c, next) => {
    if (!roles.includes(c.var.auth.role)) throw new AppError(403, 'forbidden', 'Your role cannot use this endpoint');
    await next();
  };
}

/**
 * Fixed-window, in-memory rate limit keyed by client and bucket. Good enough for one
 * instance; behind several, move the counters to Redis (same interface). `limit = 0` disables.
 */
export function rateLimit(opts: { bucket: string; limit: number; windowMs: number; now: () => Date }): MiddlewareHandler<AppEnv> {
  const hits = new Map<string, { count: number; resetAt: number }>();
  return async (c, next) => {
    if (opts.limit <= 0) return next();
    const ip = c.req.header('x-forwarded-for')?.split(',')[0]?.trim() ?? 'local';
    const key = `${opts.bucket}:${ip}`;
    const t = opts.now().getTime();
    const cur = hits.get(key);
    if (!cur || cur.resetAt <= t) {
      hits.set(key, { count: 1, resetAt: t + opts.windowMs });
    } else if (++cur.count > opts.limit) {
      c.header('retry-after', String(Math.ceil((cur.resetAt - t) / 1000)));
      throw tooMany();
    }
    if (hits.size > 10_000) for (const [k, v] of hits) if (v.resetAt <= t) hits.delete(k);
    return next();
  };
}

/**
 * Replays the stored response for a repeated `Idempotency-Key`, so a flaky connection or a
 * queued offline write can be retried safely. Keyed per person. The same key with a different
 * request is rejected. 5xx responses are not stored (the client may retry for real).
 */
export function idempotency(deps: Deps): MiddlewareHandler<AppEnv> {
  return async (c, next) => {
    const key = c.req.header('idempotency-key');
    if (!key || c.req.method === 'GET') return next();
    if (key.length > 100) throw unprocessable('Idempotency-Key is too long', 'invalid_idempotency_key');

    const personId = c.var.auth.personId;
    const body = await c.req.raw.clone().text();
    const hash = createHash('sha256').update(`${c.req.method} ${c.req.path}\n${body}`).digest('hex');

    const claim = await deps.db.asService(async (tx) => {
      const ins = await tx.query(
        `insert into idempotency_keys (person_id, key, request_hash, status) values ($1, $2, $3, 0)
         on conflict do nothing`,
        [personId, key, hash],
      );
      if (ins.rowCount === 1) return { state: 'new' as const };
      const cur = await tx.query<{ request_hash: string; status: number; body: unknown }>(
        'select request_hash, status, body from idempotency_keys where person_id = $1 and key = $2',
        [personId, key],
      );
      return { state: 'existing' as const, row: cur.rows[0]! };
    });

    if (claim.state === 'existing') {
      const { row } = claim;
      if (row.request_hash !== hash) {
        throw unprocessable('This Idempotency-Key was already used with a different request', 'idempotency_key_reused');
      }
      if (row.status === 0) throw conflict('An identical request is still being processed', 'request_in_progress');
      c.header('idempotent-replay', 'true');
      return row.status === 204 || row.body == null
        ? c.body(null, row.status as 204)
        : c.json(row.body as object, row.status as 200);
    }

    let stored = false;
    try {
      await next();
      const res = c.res.clone();
      if (res.status < 500) {
        const text = await res.text();
        await deps.db.asService((tx) =>
          tx.query('update idempotency_keys set status = $3, body = $4 where person_id = $1 and key = $2', [
            personId,
            key,
            res.status,
            text ? text : null,
          ]),
        );
        stored = true;
      }
    } finally {
      if (!stored) {
        await deps.db
          .asService((tx) => tx.query('delete from idempotency_keys where person_id = $1 and key = $2', [personId, key]))
          .catch(() => undefined);
      }
    }
  };
}

export { toProblem };
