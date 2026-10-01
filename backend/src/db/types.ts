/**
 * The whole database surface the application sees. Two implementations exist
 * (PGlite for dev/test, node-postgres for production) and both must behave the same,
 * which is why the interface is deliberately tiny.
 */

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type Row = Record<string, any>;

export interface QueryResult<T> {
  rows: T[];
  /** Rows affected by INSERT/UPDATE/DELETE, or rows returned by SELECT. */
  rowCount: number;
}

export interface Tx {
  query<T extends Row = Row>(sql: string, params?: readonly unknown[]): Promise<QueryResult<T>>;
  /** Run one or more statements with no parameters (migrations, seeds). */
  exec(sql: string): Promise<void>;
  /**
   * Run `fn` inside a savepoint. If it throws, only its own effects are rolled back
   * and the error is rethrown, so a batch can keep going after one bad entry.
   */
  attempt<T>(fn: () => Promise<T>): Promise<T>;
}

export interface Db {
  /**
   * Run `fn` in one transaction as a signed-in person: the non-superuser `app_user` role
   * with `app.person_id` set. Row-level security applies to every statement.
   */
  asUser<T>(personId: string, fn: (tx: Tx) => Promise<T>): Promise<T>;
  /**
   * Run `fn` in one transaction with service privileges (RLS bypassed). Only for
   * authentication, webhooks, the notification worker and idempotency bookkeeping.
   */
  asService<T>(fn: (tx: Tx) => Promise<T>): Promise<T>;
  /** Cheap reachability check for /readyz. */
  ping(): Promise<void>;
  close(): Promise<void>;
}

/** Driver-level statement runner; `withSavepoints` adds `attempt` on top. */
export interface RawTx {
  query<T extends Row = Row>(sql: string, params?: readonly unknown[]): Promise<QueryResult<T>>;
  exec(sql: string): Promise<void>;
}

export function withSavepoints(raw: RawTx): Tx {
  let depth = 0;
  return {
    query: (sql, params) => raw.query(sql, params),
    exec: (sql) => raw.exec(sql),
    async attempt<T>(fn: () => Promise<T>): Promise<T> {
      const name = `sp_${++depth}`;
      await raw.exec(`savepoint ${name}`);
      try {
        const out = await fn();
        await raw.exec(`release savepoint ${name}`);
        return out;
      } catch (err) {
        await raw.exec(`rollback to savepoint ${name}`);
        await raw.exec(`release savepoint ${name}`);
        throw err;
      }
    },
  };
}

/** Postgres type OIDs we override so dates stay plain strings (no timezone surprises). */
export const OID_DATE = 1082;
