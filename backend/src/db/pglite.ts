import { mkdirSync } from 'node:fs';
import { PGlite } from '@electric-sql/pglite';
import { OID_DATE, withSavepoints, type Db, type RawTx, type Tx } from './types.ts';

interface PgliteTx {
  query<T>(sql: string, params?: unknown[]): Promise<{ rows: T[]; affectedRows?: number }>;
  exec(sql: string): Promise<unknown>;
}

function adapt(t: PgliteTx): RawTx {
  return {
    async query<T>(sql: string, params: readonly unknown[] = []) {
      const r = await t.query<T>(sql, [...params]);
      // PGlite reports affectedRows: 0 for SELECT, so rows returned wins when there are any.
      return { rows: r.rows, rowCount: r.rows.length > 0 ? r.rows.length : (r.affectedRows ?? 0) } as never;
    },
    async exec(sql: string) {
      await t.exec(sql);
    },
  };
}

/**
 * Embedded Postgres: no install, no accounts. In-memory when `dataDir` is omitted (tests),
 * persisted to a directory otherwise (local development).
 */
export async function openPglite(opts: { dataDir?: string } = {}): Promise<Db> {
  if (opts.dataDir) mkdirSync(opts.dataDir, { recursive: true });
  const pg = new PGlite({
    ...(opts.dataDir ? { dataDir: opts.dataDir } : {}),
    parsers: { [OID_DATE]: (v: string) => v },
  });
  await pg.waitReady;

  const run = <T>(fn: (tx: Tx) => Promise<T>, prelude?: (raw: RawTx) => Promise<void>) =>
    pg.transaction(async (t) => {
      const raw = adapt(t as unknown as PgliteTx);
      if (prelude) await prelude(raw);
      return fn(withSavepoints(raw));
    });

  return {
    asService: (fn) => run(fn),
    asUser: (personId, fn) =>
      run(fn, async (raw) => {
        await raw.exec('set local role app_user');
        await raw.query(`select set_config('app.person_id', $1, true)`, [personId]);
      }),
    async ping() {
      await pg.query('select 1');
    },
    async close() {
      await pg.close();
    },
  };
}
