import pg from 'pg';
import { OID_DATE, withSavepoints, type Db, type RawTx, type Tx } from './types.ts';

function adapt(client: pg.PoolClient): RawTx {
  return {
    async query<T extends pg.QueryResultRow>(sql: string, params: readonly unknown[] = []) {
      const r = await client.query<T>(sql, [...params]);
      return { rows: r.rows, rowCount: r.rowCount ?? r.rows.length };
    },
    async exec(sql: string) {
      await client.query(sql);
    },
  };
}

/**
 * Production driver. The connecting role must be allowed to `SET ROLE app_user`
 * (`GRANT app_user TO <api role>`); that is what puts RLS in force for user requests.
 */
export function openPostgres(connectionString: string, opts: { max?: number } = {}): Db {
  const pool = new pg.Pool({
    connectionString,
    max: opts.max ?? 10,
    types: {
      getTypeParser: ((oid: number, format?: 'text' | 'binary') =>
        oid === OID_DATE ? (v: string) => v : pg.types.getTypeParser(oid, format as 'text')) as never,
    },
  });

  async function run<T>(fn: (tx: Tx) => Promise<T>, prelude?: (raw: RawTx) => Promise<void>): Promise<T> {
    const client = await pool.connect();
    const raw = adapt(client);
    try {
      await client.query('begin');
      if (prelude) await prelude(raw);
      const out = await fn(withSavepoints(raw));
      await client.query('commit');
      return out;
    } catch (err) {
      await client.query('rollback').catch(() => undefined);
      throw err;
    } finally {
      client.release();
    }
  }

  return {
    asService: (fn) => run(fn),
    asUser: (personId, fn) =>
      run(fn, async (raw) => {
        await raw.exec('set local role app_user');
        await raw.query(`select set_config('app.person_id', $1, true)`, [personId]);
      }),
    async ping() {
      await pool.query('select 1');
    },
    async close() {
      await pool.end();
    },
  };
}
