import { serve } from '@hono/node-server';
import { createApp } from './app.ts';
import { createDeps } from './bootstrap.ts';
import { loadConfig } from './config.ts';
import { seedDemo } from './dev/seed.ts';
import { startJobs } from './jobs/scheduler.ts';

const config = loadConfig();
const deps = await createDeps(config);
const { log } = deps;

if (config.SEED_DEMO && config.NODE_ENV !== 'production') {
  const r = await seedDemo(deps.db, config.DEMO_PASSWORD);
  if (r.seeded) log.info('demo school seeded', { password: config.DEMO_PASSWORD });
}

const app = createApp(deps);
const jobs = startJobs(deps);
const server = serve({ fetch: app.fetch, port: config.PORT }, (info) => log.info('listening', { port: info.port }));

// Graceful shutdown: stop accepting connections, let in-flight requests finish, close the database.
let closing = false;
async function shutdown(signal: string) {
  if (closing) return;
  closing = true;
  log.info('shutting down', { signal });
  const force = setTimeout(() => process.exit(1), 10_000);
  force.unref();
  await new Promise<void>((resolve) => server.close(() => resolve()));
  await jobs.stop();
  await deps.db.close();
  process.exit(0);
}
process.on('SIGTERM', () => void shutdown('SIGTERM'));
process.on('SIGINT', () => void shutdown('SIGINT'));
process.on('unhandledRejection', (err) => log.error('unhandled rejection', { err }));
