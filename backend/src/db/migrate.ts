import { createHash } from 'node:crypto';
import { readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import type { Db } from './types.ts';

export const MIGRATIONS_DIR = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'migrations');

export interface MigrationFile {
  name: string;
  sql: string;
  checksum: string;
}

export function readMigrations(dir = MIGRATIONS_DIR): MigrationFile[] {
  return readdirSync(dir)
    .filter((f) => f.endsWith('.sql'))
    .sort()
    .map((name) => {
      const sql = readFileSync(join(dir, name), 'utf8');
      return { name, sql, checksum: createHash('sha256').update(sql).digest('hex') };
    });
}

/**
 * Apply pending migrations, each in its own transaction, and refuse to start if an
 * already-applied migration was edited (they are append-only; change = new file).
 * Safe to run on every boot and from several instances at once (advisory lock is
 * unnecessary for PGlite; on Postgres the `schema_migrations` primary key makes a
 * racing second runner fail cleanly instead of double-applying).
 */
export async function migrate(db: Db, dir = MIGRATIONS_DIR): Promise<{ applied: string[] }> {
  await db.asService((tx) =>
    tx.exec(`create table if not exists schema_migrations (
      name text primary key, checksum text not null, applied_at timestamptz not null default now())`),
  );
  const done = await db.asService((tx) =>
    tx.query<{ name: string; checksum: string }>('select name, checksum from schema_migrations'),
  );
  const known = new Map(done.rows.map((r) => [r.name, r.checksum]));
  const applied: string[] = [];

  for (const m of readMigrations(dir)) {
    const prior = known.get(m.name);
    if (prior !== undefined) {
      if (prior !== m.checksum) {
        throw new Error(
          `Migration ${m.name} was edited after being applied. Migrations are append-only: revert the edit and add a new migration.`,
        );
      }
      continue;
    }
    await db.asService(async (tx) => {
      await tx.exec(m.sql);
      await tx.query('insert into schema_migrations (name, checksum) values ($1, $2)', [m.name, m.checksum]);
    });
    applied.push(m.name);
  }
  return { applied };
}

/** For /readyz: are all migrations on disk applied? */
export async function migrationsCurrent(db: Db, dir = MIGRATIONS_DIR): Promise<boolean> {
  const r = await db.asService((tx) => tx.query<{ name: string }>('select name from schema_migrations'));
  const have = new Set(r.rows.map((x) => x.name));
  return readMigrations(dir).every((m) => have.has(m.name));
}
