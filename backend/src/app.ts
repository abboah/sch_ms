import { Hono } from 'hono';
import { bodyLimit } from 'hono/body-limit';
import { cors } from 'hono/cors';
import type { AppEnv, Deps } from './context.ts';
import { migrationsCurrent } from './db/migrate.ts';
import { AppError } from './http/errors.ts';
import { authenticate, errorHandler, idempotency, requestContext } from './http/middleware.ts';
import { authRoutes } from './modules/auth/routes.ts';
import { adminRoutes } from './modules/admin/routes.ts';
import { announcementRoutes } from './modules/announcements/routes.ts';
import { attendanceRoutes } from './modules/attendance/routes.ts';
import { classRoutes } from './modules/classes/routes.ts';
import { conferenceRoutes } from './modules/conferences/routes.ts';
import { devRoutes } from './modules/dev/routes.ts';
import { feesRoutes, webhookRoutes } from './modules/fees/routes.ts';
import { gradebookRoutes } from './modules/gradebook/routes.ts';
import { gradingRoutes } from './modules/grading/routes.ts';
import { homeworkRoutes } from './modules/homework/routes.ts';
import { meRoutes } from './modules/me/routes.ts';
import { messagingRoutes } from './modules/messaging/routes.ts';
import { onboardingRoutes } from './modules/onboarding/routes.ts';
import { reportCommentRoutes } from './modules/reportcomments/routes.ts';
import { studentRoutes } from './modules/students/routes.ts';

/**
 * Builds the whole HTTP application from injected dependencies. Nothing here reads the
 * environment or opens a connection, so tests construct it in-process and call
 * `app.request(...)` with no network.
 */
export function createApp(deps: Deps): Hono<AppEnv> {
  const app = new Hono<AppEnv>();
  const origins = deps.config.CORS_ORIGINS === '*' ? '*' : deps.config.CORS_ORIGINS.split(',').map((s) => s.trim());

  app.use('*', requestContext(deps));
  app.use(
    '*',
    cors({
      origin: origins,
      allowHeaders: ['authorization', 'content-type', 'idempotency-key', 'x-request-id'],
      exposeHeaders: ['x-request-id', 'retry-after', 'idempotent-replay'],
      maxAge: 600,
    }),
  );
  app.use(
    '*',
    bodyLimit({
      maxSize: 1_000_000,
      onError: () => {
        throw new AppError(413, 'payload_too_large', 'Request body is too large');
      },
    }),
  );
  app.onError(errorHandler());
  app.notFound(() => {
    throw new AppError(404, 'not_found', 'No such endpoint');
  });

  // Liveness: the process is up. Readiness: it can actually serve (database reachable, schema current).
  app.get('/healthz', (c) => c.json({ status: 'ok' }));
  app.get('/readyz', async (c) => {
    try {
      await deps.db.ping();
      const current = await migrationsCurrent(deps.db);
      return c.json({ status: current ? 'ready' : 'migrations_pending' }, current ? 200 : 503);
    } catch (err) {
      c.var.log.error('readiness check failed', { err });
      return c.json({ status: 'database_unreachable' }, 503);
    }
  });

  const v1 = new Hono<AppEnv>();
  v1.route('/auth', authRoutes(deps));
  v1.route('/', onboardingRoutes(deps)); // POST /schools: no login exists yet either
  v1.route('/webhooks', webhookRoutes(deps)); // verified by signature, not by login
  const dev = devRoutes(deps); // null outside development
  if (dev) v1.route('/dev', dev);

  const authed = new Hono<AppEnv>();
  authed.use('*', authenticate(deps));
  authed.use('*', idempotency(deps));
  for (const routes of [
    meRoutes, studentRoutes, classRoutes, attendanceRoutes, gradebookRoutes, gradingRoutes, reportCommentRoutes, feesRoutes,
    messagingRoutes, announcementRoutes, homeworkRoutes, conferenceRoutes, adminRoutes,
  ]) {
    authed.route('/', routes(deps));
  }
  v1.route('/', authed);

  app.route('/v1', v1);
  return app;
}
