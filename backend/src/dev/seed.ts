import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { hashPassword } from '../auth/passwords.ts';
import type { Db } from '../db/types.ts';

const SEED_SQL = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'seed', 'seed.sql');

/**
 * Load the demo school (Greenfield Academy) and create a login for every adult in it.
 * Email is `first.last@greenfield.edu.gh` and guardians also get their phone for OTP sign-in.
 * Idempotent: does nothing if the database already has schools. Development only.
 */
export async function seedDemo(db: Db, password: string): Promise<{ seeded: boolean }> {
  const has = await db.asService((tx) => tx.query('select 1 from schools limit 1'));
  if (has.rowCount > 0) return { seeded: false };

  await db.asService((tx) => tx.exec(readFileSync(SEED_SQL, 'utf8')));
  const hash = await hashPassword(password); // one hash shared by all demo accounts

  await db.asService(async (tx) => {
    const adults = await tx.query<{ id: string; email: string; phone: string | null; role: string; school_id: string }>(
      `select p.id, p.role, p.school_id, c.email, c.phone
         from people p join person_contacts c on c.person_id = p.id
        where p.role <> 'student' and c.email is not null`,
    );
    for (const a of adults.rows) {
      const acct = await tx.query<{ id: string }>(
        `insert into accounts (email, phone, password_hash) values ($1, $2, $3) returning id`,
        [a.email, a.role === 'guardian' ? a.phone : null, hash],
      );
      await tx.query('update people set auth_user_id = $1 where id = $2', [acct.rows[0]!.id, a.id]);
    }
  });
  return { seeded: true };
}
