import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps } from '../../context.ts';
import { createAuthService } from '../../auth/service.ts';
import { normalizePhone } from '../../auth/phone.ts';
import { hashToken } from '../../auth/tokens.ts';
import { badRequest } from '../../http/errors.ts';
import { body, type Schemas } from '../../http/helpers.ts';
import { rateLimit } from '../../http/middleware.ts';

/**
 * Lets a school create itself: redeem a one-time invite code (minted by an operator via
 * `node src/cli.ts create-invite`) into a new school and its first admin account. No login
 * exists yet, so this runs entirely as the service role, the same as sign-in and OTP.
 */
export function onboardingRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();
  const auth = createAuthService(deps);
  const limited = rateLimit({ bucket: 'onboard', limit: deps.config.AUTH_RATE_LIMIT_PER_MINUTE, windowMs: 60_000, now: deps.clock.now });

  r.post('/schools', limited, async (c) => {
    const b = await body(
      c,
      z.object({
        invite_code: z.string().min(1).max(200),
        school_name: z.string().trim().min(1).max(200),
        timezone: z.string().trim().min(1).max(64).default('Africa/Accra'),
        admin: z
          .object({
            full_name: z.string().trim().min(1).max(120),
            email: z.email().optional(),
            phone: z.string().min(6).max(25).optional(),
          })
          .refine((a) => a.email || a.phone, { message: 'email or phone is required', path: ['email'] }),
      }),
    );
    const phone = b.admin.phone ? normalizePhone(b.admin.phone, deps.config.DEFAULT_COUNTRY_CODE) : null;
    const email = b.admin.email ? b.admin.email.toLowerCase() : null;
    const codeHash = hashToken(b.invite_code);
    const now = deps.clock.now();

    const { school, adminId } = await deps.db.asService(async (tx) => {
      const invite = await tx.query<{ id: string }>(
        `select id from school_invites where code_hash = $1 and used_at is null and expires_at > $2 for update`,
        [codeHash, now],
      );
      const inviteId = invite.rows[0]?.id;
      if (!inviteId) throw badRequest('This invite code is invalid, used, or expired', 'invalid_invite_code');

      const s = await tx.query<{ id: string; name: string; timezone: string }>(
        `insert into schools (name, timezone) values ($1, $2) returning id, name, timezone`,
        [b.school_name, b.timezone],
      );
      const school = s.rows[0]!;

      const p = await tx.query<{ id: string }>(
        `insert into people (school_id, full_name, role) values ($1, $2, 'admin') returning id`,
        [school.id, b.admin.full_name],
      );
      const adminId = p.rows[0]!.id;
      if (phone || email) {
        await tx.query('insert into person_contacts (person_id, school_id, phone, email) values ($1, $2, $3, $4)', [
          adminId,
          school.id,
          phone,
          email,
        ]);
      }
      await tx.query('update school_invites set used_at = $2, used_by_school_id = $3 where id = $1', [inviteId, now, school.id]);
      return { school, adminId };
    });

    await auth.inviteAccount(adminId, { email, phone });

    const out: Schemas['School'] = { id: school.id, name: school.name, timezone: school.timezone };
    return c.json(out, 201);
  });

  return r;
}
