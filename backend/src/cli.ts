import { loadConfig } from './config.ts';
import { createDeps } from './bootstrap.ts';
import { seedDemo } from './dev/seed.ts';
import { newRefreshToken } from './auth/tokens.ts';

const cmd = process.argv[2];
const config = loadConfig();

if (cmd === 'migrate') {
  const deps = await createDeps(config); // createDeps applies pending migrations
  deps.log.info('schema is up to date');
  await deps.db.close();
} else if (cmd === 'seed') {
  if (config.NODE_ENV === 'production') {
    console.error('Refusing to seed the demo school in production.');
    process.exit(1);
  }
  const deps = await createDeps(config);
  const r = await seedDemo(deps.db, config.DEMO_PASSWORD);
  deps.log.info(r.seeded ? 'demo school seeded' : 'database already has data, nothing to do');
  await deps.db.close();
} else if (cmd === 'create-invite') {
  const flagIdx = process.argv.indexOf('--expires-in-days');
  const days = flagIdx !== -1 ? Number(process.argv[flagIdx + 1]) : 14;
  const deps = await createDeps(config);
  const { token, hash } = newRefreshToken();
  const expiresAt = new Date(Date.now() + days * 24 * 3600 * 1000);
  await deps.db.asService((tx) => tx.query('insert into school_invites (code_hash, expires_at) values ($1, $2)', [hash, expiresAt]));
  deps.log.info('school invite created: hand this code to the new school, it is shown once', {
    code: token,
    expires_at: expiresAt.toISOString(),
  });
  await deps.db.close();
} else {
  console.error('usage: node src/cli.ts <migrate|seed|create-invite [--expires-in-days N]>');
  process.exit(1);
}
