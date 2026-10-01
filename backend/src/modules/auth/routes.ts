import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps } from '../../context.ts';
import { createAuthService } from '../../auth/service.ts';
import { authenticate, rateLimit } from '../../http/middleware.ts';
import { body, uuid } from '../../http/helpers.ts';

export function authRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();
  const auth = createAuthService(deps);
  const limited = (bucket: string) =>
    rateLimit({ bucket, limit: deps.config.AUTH_RATE_LIMIT_PER_MINUTE, windowMs: 60_000, now: deps.clock.now });

  r.post('/sessions', limited('signin'), async (c) => {
    const { email, password } = await body(c, z.object({ email: z.email(), password: z.string().min(1).max(200) }));
    return c.json(await auth.signInWithPassword(email, password));
  });

  r.post('/sessions/select', limited('select'), async (c) => {
    const b = await body(c, z.object({ selection_token: z.string().min(1), person_id: uuid }));
    return c.json(await auth.selectPerson(b.selection_token, b.person_id));
  });

  r.delete('/sessions/current', authenticate(deps), async (c) => {
    await auth.signOut(c.var.auth.sessionId);
    return c.body(null, 204);
  });

  r.post('/refresh', limited('refresh'), async (c) => {
    const { refresh_token } = await body(c, z.object({ refresh_token: z.string().min(1) }));
    return c.json(await auth.refresh(refresh_token));
  });

  r.post('/otp', limited('otp'), async (c) => {
    const { phone } = await body(c, z.object({ phone: z.string().min(6).max(25) }));
    await auth.requestOtp(phone);
    return c.body(null, 204);
  });

  r.post('/otp/verify', limited('otp-verify'), async (c) => {
    const { phone, code } = await body(c, z.object({ phone: z.string().min(6).max(25), code: z.string().regex(/^\d{6}$/) }));
    return c.json(await auth.verifyOtp(phone, code));
  });

  r.post('/password/forgot', limited('pw-forgot'), async (c) => {
    const { email } = await body(c, z.object({ email: z.email() }));
    await auth.requestPasswordReset(email);
    return c.body(null, 204);
  });

  r.post('/password/reset', limited('pw-reset'), async (c) => {
    const b = await body(c, z.object({ token: z.string().min(10).max(200), new_password: z.string().min(8).max(200) }));
    await auth.resetPassword(b.token, b.new_password);
    return c.body(null, 204);
  });

  return r;
}
