import { createHmac, randomInt, randomUUID, timingSafeEqual } from 'node:crypto';
import type { Deps } from '../context.ts';
import { AppError, forbidden, tooMany, unauthorized } from '../http/errors.ts';
import type { Schemas } from '../http/helpers.ts';
import { loadMe } from '../modules/me/service.ts';
import { normalizePhone } from './phone.ts';
import { dummyHash, hashPassword, verifyPassword } from './passwords.ts';
import { hashToken, newRefreshToken, type Role } from './tokens.ts';

const OTP_TTL_MS = 10 * 60 * 1000;
const OTP_MAX_ATTEMPTS = 5;
const OTP_MAX_PER_HOUR = 5;
const SELECTION_TTL_SECONDS = 5 * 60;
const RESET_TTL_MS = 60 * 60 * 1000;
const INVITE_TTL_MS = 7 * 24 * 60 * 60 * 1000;

export type SignInResult = Schemas['SignInResult'];

/**
 * Authentication: accounts, sessions, refresh rotation, OTP. The only module (besides
 * payments and the notification worker) that uses service-role access, because sign-in
 * happens before there is a person to run as.
 */
export function createAuthService(deps: Deps) {
  const { db, config, clock, tokens } = deps;
  const invalidCredentials = () => unauthorized('Incorrect email or password', 'invalid_credentials');

  async function createSession(accountId: string, personId: string, familyId: string = randomUUID()): Promise<Schemas['Session']> {
    const refresh = newRefreshToken();
    const now = clock.now();
    const person = await db.asService(async (tx) => {
      const r = await tx.query<{ role: Role; school_id: string }>('select role, school_id from people where id = $1', [personId]);
      const row = r.rows[0];
      if (!row) throw forbidden('This person no longer exists', 'no_active_membership');
      await tx.query(
        `insert into refresh_tokens (family_id, account_id, person_id, token_hash, expires_at)
         values ($1, $2, $3, $4, $5)`,
        [familyId, accountId, personId, refresh.hash, new Date(now.getTime() + config.REFRESH_TOKEN_TTL_SECONDS * 1000)],
      );
      return row;
    });
    const access = await tokens.signAccess(
      { personId, role: person.role, schoolId: person.school_id, sessionId: familyId },
      config.ACCESS_TOKEN_TTL_SECONDS,
    );
    const me = await db.asUser(personId, (tx) => loadMe(tx, personId, clock.now()));
    return { access_token: access, refresh_token: refresh.token, expires_in: config.ACCESS_TOKEN_TTL_SECONDS, me };
  }

  /** One person: session. Several (an admin who is also a parent): ask which. None: refuse. */
  async function resolveAccount(accountId: string): Promise<SignInResult> {
    const people = await db.asService((tx) =>
      tx.query<{ id: string; role: Schemas['Role']; full_name: string; school_name: string }>(
        `select p.id, p.role, p.full_name, s.name as school_name
           from people p join schools s on s.id = p.school_id
          where p.auth_user_id = $1 order by s.name, p.role`,
        [accountId],
      ),
    );
    if (people.rows.length === 0) throw forbidden('This account is not linked to any school', 'no_active_membership');
    if (people.rows.length === 1) return { status: 'signed_in', session: await createSession(accountId, people.rows[0]!.id) };
    return {
      status: 'selection_required',
      selection: {
        selection_token: await tokens.signSelection(accountId, SELECTION_TTL_SECONDS),
        choices: people.rows.map((p) => ({ person_id: p.id, role: p.role, school_name: p.school_name, full_name: p.full_name })),
      },
    };
  }

  const otpHash = (phone: string, code: string) => createHmac('sha256', config.JWT_SECRET).update(`${phone}:${code}`).digest('hex');

  return {
    createSession,

    async signInWithPassword(email: string, password: string): Promise<SignInResult> {
      const acct = await db.asService(async (tx) => {
        const r = await tx.query<{ id: string; password_hash: string | null; disabled_at: Date | null }>(
          'select id, password_hash, disabled_at from accounts where email = $1',
          [email.trim().toLowerCase()],
        );
        return r.rows[0];
      });
      // Always burn one hash comparison so a missing account is not faster than a wrong password.
      const ok = await verifyPassword(password, acct?.password_hash ?? (await dummyHash()));
      if (!acct || !acct.password_hash || !ok || acct.disabled_at) throw invalidCredentials();
      return resolveAccount(acct.id);
    },

    async selectPerson(selectionToken: string, personId: string): Promise<Schemas['Session']> {
      const { accountId } = await tokens.verifySelection(selectionToken);
      const owns = await db.asService((tx) =>
        tx.query('select 1 from people where id = $1 and auth_user_id = $2', [personId, accountId]),
      );
      if (owns.rowCount === 0) throw forbidden('That role does not belong to this account', 'invalid_selection');
      return createSession(accountId, personId);
    },

    /**
     * Refresh tokens are single-use and rotate. Presenting one that was already used means it
     * leaked (or a client is buggy), so the whole family is revoked and the user signs in again.
     */
    async refresh(token: string): Promise<Schemas['Session']> {
      const now = clock.now();
      const outcome = await db.asService(async (tx) => {
        const r = await tx.query<{
          id: string; family_id: string; account_id: string; person_id: string; expires_at: Date; revoked_at: Date | null;
        }>(
          `select id, family_id, account_id, person_id, expires_at, revoked_at
             from refresh_tokens where token_hash = $1 for update`,
          [hashToken(token)],
        );
        const row = r.rows[0];
        if (!row) return { kind: 'invalid' as const };
        if (row.revoked_at) {
          await tx.query('update refresh_tokens set revoked_at = $2 where family_id = $1 and revoked_at is null', [row.family_id, now]);
          return { kind: 'reused' as const };
        }
        if (row.expires_at <= now) return { kind: 'expired' as const };
        await tx.query('update refresh_tokens set revoked_at = $2 where id = $1', [row.id, now]);
        return { kind: 'ok' as const, row };
      });
      if (outcome.kind === 'invalid') throw unauthorized('Invalid refresh token', 'invalid_refresh_token');
      if (outcome.kind === 'reused') throw unauthorized('Session revoked, please sign in again', 'refresh_token_reused');
      if (outcome.kind === 'expired') throw unauthorized('Session expired, please sign in again', 'refresh_token_expired');
      const disabled = await db.asService((tx) => tx.query('select 1 from accounts where id = $1 and disabled_at is not null', [outcome.row.account_id]));
      if (disabled.rowCount) throw unauthorized('Account disabled', 'account_disabled');
      return createSession(outcome.row.account_id, outcome.row.person_id, outcome.row.family_id);
    },

    async signOut(sessionId: string): Promise<void> {
      await db.asService((tx) =>
        tx.query('update refresh_tokens set revoked_at = $2 where family_id = $1 and revoked_at is null', [sessionId, clock.now()]),
      );
    },


    /** Always succeeds from the caller's view, so it cannot reveal which emails have accounts. */
    async requestPasswordReset(email: string): Promise<void> {
      const now = clock.now();
      const found = await db.asService(async (tx) => {
        const a = await tx.query<{ id: string }>('select id from accounts where email = $1 and disabled_at is null', [email.trim().toLowerCase()]);
        const acct = a.rows[0];
        if (!acct) return null;
        const { token, hash } = newRefreshToken();
        await tx.query('insert into password_resets (account_id, token_hash, expires_at, created_at) values ($1, $2, $3, $4)', [
          acct.id, hash, new Date(now.getTime() + RESET_TTL_MS), now,
        ]);
        return token;
      });
      if (found) {
        const link = `${config.PUBLIC_WEB_URL}/#/reset?token=${found}`;
        await deps.email.send(email.trim().toLowerCase(), 'Reset your Homeroom password', `Use this link within one hour to choose a new password:
${link}

If you did not ask for this, ignore this message.`);
      }
    },

    /** Sets the password from a reset or invitation link, then signs the account out everywhere. */
    async resetPassword(token: string, newPassword: string): Promise<void> {
      const now = clock.now();
      const hash = await hashPassword(newPassword);
      const ok = await db.asService(async (tx) => {
        const r = await tx.query<{ id: string; account_id: string }>(
          `select id, account_id from password_resets
            where token_hash = $1 and used_at is null and expires_at > $2 for update`,
          [hashToken(token), now],
        );
        const row = r.rows[0];
        if (!row) return false;
        await tx.query('update password_resets set used_at = $2 where id = $1', [row.id, now]);
        await tx.query('update accounts set password_hash = $2 where id = $1', [row.account_id, hash]);
        await tx.query('update refresh_tokens set revoked_at = $2 where account_id = $1 and revoked_at is null', [row.account_id, now]);
        return true;
      });
      if (!ok) throw new AppError(400, 'invalid_reset_token', 'This link is invalid or has expired. Request a new one.');
    },

    /**
     * Give a person a login. If the email or phone already belongs to an account (for example a
     * teacher who is also a parent at the school) the person is linked to it instead, so one sign-in
     * covers both roles. Staff with an email get a set-password link; guardians with only a phone sign in by SMS code.
     */
    async inviteAccount(personId: string, contact: { email?: string | null; phone?: string | null }): Promise<void> {
      const email = contact.email?.trim().toLowerCase() || null;
      const phone = contact.phone ? normalizePhone(contact.phone, config.DEFAULT_COUNTRY_CODE) : null;
      if (!email && !phone) return;
      const now = clock.now();
      const outcome = await db.asService(async (tx) => {
        const existing = await tx.query<{ id: string }>(
          'select id from accounts where ($1::text is not null and email = $1) or ($2::text is not null and phone = $2) limit 1',
          [email, phone],
        );
        let accountId = existing.rows[0]?.id;
        let isNew = false;
        if (!accountId) {
          const a = await tx.query<{ id: string }>('insert into accounts (email, phone) values ($1, $2) returning id', [email, phone]);
          accountId = a.rows[0]!.id;
          isNew = true;
        }
        await tx.query('update people set auth_user_id = $1 where id = $2', [accountId, personId]);
        if (!isNew || !email) return { isNew, token: null as string | null };
        const { token, hash } = newRefreshToken();
        await tx.query('insert into password_resets (account_id, token_hash, expires_at, created_at) values ($1, $2, $3, $4)', [
          accountId, hash, new Date(now.getTime() + INVITE_TTL_MS), now,
        ]);
        return { isNew, token };
      });
      if (outcome.token && email) {
        await deps.email.send(email, 'Welcome to Homeroom', `Your school has created a Homeroom account for you. Choose a password within 7 days:
${config.PUBLIC_WEB_URL}/#/reset?token=${outcome.token}`);
      } else if (outcome.isNew && phone) {
        await deps.sms.send(phone, `Your school has added you to Homeroom. Open ${config.PUBLIC_WEB_URL} and sign in with your mobile number: we will text you a code.`);
      }
    },

    /** Always succeeds from the caller's view, so it cannot be used to discover which numbers have accounts. */
    async requestOtp(rawPhone: string): Promise<void> {
      const phone = normalizePhone(rawPhone, config.DEFAULT_COUNTRY_CODE);
      const now = clock.now();
      const code = randomInt(0, 1_000_000).toString().padStart(6, '0');
      const send = await db.asService(async (tx) => {
        const recent = await tx.query<{ n: number }>(
          'select count(*)::int as n from otp_codes where phone = $1 and created_at > $2',
          [phone, new Date(now.getTime() - 3600_000)],
        );
        if ((recent.rows[0]?.n ?? 0) >= OTP_MAX_PER_HOUR) throw tooMany('Too many codes requested. Try again later.');
        const acct = await tx.query('select 1 from accounts where phone = $1 and disabled_at is null', [phone]);
        await tx.query('insert into otp_codes (phone, code_hash, expires_at, created_at) values ($1, $2, $3, $4)', [
          phone, otpHash(phone, code), new Date(now.getTime() + OTP_TTL_MS), now,
        ]);
        return acct.rowCount > 0;
      });
      if (send) await deps.sms.send(phone, `Your Homeroom code is ${code}. It expires in 10 minutes.`);
    },

    async verifyOtp(rawPhone: string, code: string): Promise<SignInResult> {
      const phone = normalizePhone(rawPhone, config.DEFAULT_COUNTRY_CODE);
      const now = clock.now();
      const accountId = await db.asService(async (tx) => {
        const r = await tx.query<{ id: string; code_hash: string; attempts: number }>(
          `select id, code_hash, attempts from otp_codes
            where phone = $1 and consumed_at is null and expires_at > $2
            order by created_at desc limit 1 for update`,
          [phone, now],
        );
        const row = r.rows[0];
        if (!row || row.attempts >= OTP_MAX_ATTEMPTS) return null;
        const good = safeEq(row.code_hash, otpHash(phone, code));
        await tx.query('update otp_codes set attempts = attempts + 1, consumed_at = $2 where id = $1', [row.id, good ? now : null]);
        if (!good) return null;
        const a = await tx.query<{ id: string }>('select id from accounts where phone = $1 and disabled_at is null', [phone]);
        return a.rows[0]?.id ?? null;
      });
      if (!accountId) throw new AppError(401, 'invalid_code', 'That code is wrong or has expired');
      return resolveAccount(accountId);
    },
  };
}

function safeEq(a: string, b: string): boolean {
  const x = Buffer.from(a);
  const y = Buffer.from(b);
  return x.length === y.length && timingSafeEqual(x, y);
}

export type AuthService = ReturnType<typeof createAuthService>;
