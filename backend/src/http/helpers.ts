import type { Context } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps, Tx } from '../context.ts';
import type { AccessClaims } from '../auth/tokens.ts';
import type { components } from '../api/schema.d.ts';
import { badRequest, notFound } from './errors.ts';

/** Response/request types come from the OpenAPI contract, so a drifting handler fails to compile. */
export type Schemas = components['schemas'];

/**
 * Shape check only (8-4-4-4-12 hex), matching Postgres's own uuid type. Not z.uuid(), which also
 * demands RFC version bits that deterministic seed/test ids do not have.
 */
export const uuid = z.string().regex(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i, 'expected a UUID');
export const isoDate = z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'expected YYYY-MM-DD');

/** Parse a JSON body against a schema; malformed JSON is a 400, a wrong shape is a 400 with field errors. */
export async function body<S extends z.ZodType>(c: Context<AppEnv>, schema: S): Promise<z.infer<S>> {
  let raw: unknown;
  try {
    raw = await c.req.json();
  } catch {
    throw badRequest('Request body must be valid JSON', 'invalid_json');
  }
  return schema.parse(raw);
}

export function query<S extends z.ZodType>(c: Context<AppEnv>, schema: S): z.infer<S> {
  return schema.parse(c.req.query());
}

export function idParam(c: Context<AppEnv>, name = 'id'): string {
  const parsed = uuid.safeParse(c.req.param(name));
  if (!parsed.success) throw notFound();
  return parsed.data;
}

/** Run a handler body in one transaction as the signed-in person (RLS in force). */
export function asCaller<T>(deps: Deps, c: Context<AppEnv>, fn: (tx: Tx, me: AccessClaims) => Promise<T>): Promise<T> {
  return deps.db.asUser(c.var.auth.personId, (tx) => fn(tx, c.var.auth));
}

/** Cursor pagination: an opaque token wrapping the last row's sort key. */
export interface Cursor {
  t: string;
  id: string;
}
export const encodeCursor = (cur: Cursor): string => Buffer.from(JSON.stringify(cur)).toString('base64url');
export function decodeCursor(token: string | undefined): Cursor | undefined {
  if (!token) return undefined;
  try {
    const v = JSON.parse(Buffer.from(token, 'base64url').toString('utf8')) as Cursor;
    if (typeof v.t === 'string' && uuid.safeParse(v.id).success) return v;
  } catch {
    /* fall through */
  }
  throw badRequest('Invalid cursor', 'invalid_cursor');
}

export const pageQuery = z.object({
  limit: z.coerce.number().int().min(1).max(200).default(50),
  cursor: z.string().optional(),
});

/** Pluck `limit + 1` rows, return the page and the next cursor if there is one. */
export function paginate<T extends { id: string }>(
  rows: T[],
  limit: number,
  sortKey: (row: T) => string,
): { items: T[]; next_cursor: string | null } {
  const items = rows.slice(0, limit);
  const last = items[items.length - 1];
  return {
    items,
    next_cursor: rows.length > limit && last ? encodeCursor({ t: sortKey(last), id: last.id }) : null,
  };
}

export const iso = (d: Date | string | null | undefined): string | null =>
  d == null ? null : d instanceof Date ? d.toISOString() : new Date(d).toISOString();

/** Decimal strings only ever leave the API as "123.45". */
export const money = (n: string | number | null | undefined): string => Number(n ?? 0).toFixed(2);
