import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { normalizePhone } from '../src/auth/phone.ts';
import { hashPassword, verifyPassword } from '../src/auth/passwords.ts';
import { loadConfig } from '../src/config.ts';
import { migrate } from '../src/db/migrate.ts';
import { openPglite } from '../src/db/pglite.ts';
import { toProblem, AppError } from '../src/http/errors.ts';
import { createLogger } from '../src/lib/logger.ts';
import { todayIn, runningGrade } from '../src/modules/shared.ts';

describe('phone numbers', () => {
  test('every way of writing a Ghanaian mobile becomes the same E.164 number', () => {
    for (const raw of ['024 410 2231', '0244102231', '+233244102231', '00233244102231', '+233 24 410 2231', '244102231']) {
      assert.equal(normalizePhone(raw, '+233'), '+233244102231', raw);
    }
  });
  test('rubbish is rejected with a clear code', () => {
    assert.throws(() => normalizePhone('12', '+233'), (e: any) => e.code === 'invalid_phone');
    assert.throws(() => normalizePhone('call me', '+233'), (e: any) => e.code === 'invalid_phone');
  });
});

describe('passwords', () => {
  test('a password verifies, a wrong one does not, and every hash is salted', async () => {
    const a = await hashPassword('correct horse battery staple');
    const b = await hashPassword('correct horse battery staple');
    assert.notEqual(a, b);
    assert.ok(a.startsWith('scrypt$'));
    assert.equal(await verifyPassword('correct horse battery staple', a), true);
    assert.equal(await verifyPassword('correct horse battery stapl', a), false);
    assert.equal(await verifyPassword('x', 'not-a-hash'), false);
  });
});

describe('configuration', () => {
  const prod = { NODE_ENV: 'production', JWT_SECRET: 'x'.repeat(40), DATABASE_URL: 'postgres://u:p@h/db', PAYMENT_WEBHOOK_SECRET: 'y'.repeat(20), CORS_ORIGINS: 'https://app.example.com', PAYMENT_GATEWAY: 'paystack', PAYSTACK_SECRET_KEY: 'sk_live_x' };

  test('development runs with no settings at all', () => {
    const c = loadConfig({});
    assert.equal(c.NODE_ENV, 'development');
    assert.equal(c.PORT, 3000);
  });
  test('production refuses to start without its secrets, real CORS origins, or the sandbox gateway', () => {
    assert.doesNotThrow(() => loadConfig(prod));
    assert.throws(() => loadConfig({ ...prod, JWT_SECRET: undefined }), /JWT_SECRET/);
    assert.throws(() => loadConfig({ ...prod, DATABASE_URL: undefined }), /DATABASE_URL/);
    assert.throws(() => loadConfig({ ...prod, CORS_ORIGINS: '*' }), /CORS_ORIGINS/);
    assert.throws(() => loadConfig({ ...prod, PAYMENT_GATEWAY: 'sandbox' }), /sandbox/);
    assert.throws(() => loadConfig({ ...prod, PAYSTACK_SECRET_KEY: undefined }), /PAYSTACK_SECRET_KEY/);
  });
  test('ALLOW_SANDBOX_PAYMENTS opts a production deploy into fake payments for MVP/eval use', () => {
    const { PAYMENT_GATEWAY, PAYSTACK_SECRET_KEY, ...rest } = prod;
    const c = loadConfig({ ...rest, ALLOW_SANDBOX_PAYMENTS: 'true' });
    assert.equal(c.PAYMENT_GATEWAY, 'sandbox');
    assert.throws(() => loadConfig({ ...rest, ALLOW_SANDBOX_PAYMENTS: 'false' }), /sandbox/);
  });
  test('malformed values fail fast with the setting\'s name', () => {
    assert.throws(() => loadConfig({ PORT: 'eighty' }), /PORT/);
    assert.throws(() => loadConfig({ JWT_SECRET: 'short' }), /JWT_SECRET/);
  });
  test('opting into a real SMS or push provider without its credentials fails fast, in any environment', () => {
    assert.doesNotThrow(() => loadConfig({})); // console/console by default, nothing required
    assert.throws(() => loadConfig({ SMS_PROVIDER: 'twilio' }), /TWILIO_ACCOUNT_SID/);
    assert.doesNotThrow(() => loadConfig({ SMS_PROVIDER: 'twilio', TWILIO_ACCOUNT_SID: 'AC1', TWILIO_AUTH_TOKEN: 't', TWILIO_FROM: '+1' }));
    assert.throws(() => loadConfig({ SMS_PROVIDER: 'hubtel' }), /HUBTEL_CLIENT_ID/);
    assert.throws(() => loadConfig({ PUSH_PROVIDER: 'fcm' }), /FCM_PROJECT_ID/);
    assert.doesNotThrow(() =>
      loadConfig({ PUSH_PROVIDER: 'fcm', FCM_PROJECT_ID: 'p', FCM_CLIENT_EMAIL: 'e@p.iam.gserviceaccount.com', FCM_PRIVATE_KEY: 'k' }),
    );
  });
});

describe('migrations are append-only', () => {
  test('editing an applied migration stops the server; adding a new one applies cleanly', async () => {
    const dir = mkdtempSync(join(tmpdir(), 'mig-'));
    writeFileSync(join(dir, '001_a.sql'), 'create table a (id int);');
    const db = await openPglite();
    assert.deepEqual((await migrate(db, dir)).applied, ['001_a.sql']);
    assert.deepEqual((await migrate(db, dir)).applied, [], 'idempotent');

    writeFileSync(join(dir, '002_b.sql'), 'create table b (id int);');
    assert.deepEqual((await migrate(db, dir)).applied, ['002_b.sql']);

    writeFileSync(join(dir, '001_a.sql'), 'create table a (id int, sneaky int);');
    await assert.rejects(migrate(db, dir), /001_a\.sql was edited after being applied/);
    await db.close();
  });

  test('a failing migration rolls back entirely and is not recorded', async () => {
    const dir = mkdtempSync(join(tmpdir(), 'mig-'));
    writeFileSync(join(dir, '001_ok.sql'), 'create table ok (id int);');
    writeFileSync(join(dir, '002_bad.sql'), 'create table half (id int); select * from does_not_exist;');
    const db = await openPglite();
    await assert.rejects(migrate(db, dir));
    const tables = await db.asService((tx) => tx.query(`select table_name from information_schema.tables where table_name in ('ok', 'half')`));
    assert.deepEqual(tables.rows.map((r) => r.table_name), ['ok']);
    const done = await db.asService((tx) => tx.query('select name from schema_migrations'));
    assert.deepEqual(done.rows.map((r) => r.name), ['001_ok.sql']);
    await db.close();
  });
});

describe('errors', () => {
  test('database failures become the right HTTP problem, and unknown ones never leak internals', () => {
    assert.equal(toProblem({ code: '42501' }).status, 403);
    assert.equal(toProblem({ code: '23505' }).code, 'already_exists');
    assert.equal(toProblem({ code: '23503' }).status, 409);
    assert.equal(toProblem({ code: '22P02' }).status, 400);
    const unknown = toProblem(new Error('password=hunter2 at db.internal:5432'), 'req-1');
    assert.equal(unknown.status, 500);
    assert.ok(!JSON.stringify(unknown).includes('hunter2'));
    assert.equal(unknown.request_id, 'req-1');
    assert.equal(toProblem(new AppError(418, 'teapot', 'short and stout')).code, 'teapot');
  });
});

describe('logger', () => {
  test('emits one JSON object per line, with bindings and error details, and honours the level', () => {
    const lines: string[] = [];
    const log = createLogger({ level: 'info', sink: (l) => lines.push(l) }).child({ requestId: 'r1' });
    log.debug('hidden');
    log.info('hello', { n: 1 });
    log.error('boom', { err: new Error('bad') });
    assert.equal(lines.length, 2);
    const a = JSON.parse(lines[0]!);
    assert.deepEqual([a.msg, a.requestId, a.n, a.level], ['hello', 'r1', 1, 'info']);
    assert.equal(JSON.parse(lines[1]!).err.message, 'bad');
  });
});

describe('small helpers', () => {
  test('"today" follows the school\'s timezone, not the server\'s', () => {
    const t = new Date('2026-10-05T23:30:00Z');
    assert.equal(todayIn('Africa/Accra', t), '2026-10-05');
    assert.equal(todayIn('Pacific/Auckland', t), '2026-10-06');
  });
  test('the running grade weights only what has been scored', () => {
    assert.equal(runningGrade([]), null);
    assert.equal(runningGrade([{ score: null, max_score: 10, weight: 50 }]), null);
    assert.equal(runningGrade([{ score: 8, max_score: 10, weight: 10 }, { score: 72, max_score: 100, weight: 25 }, { score: 15, max_score: 20, weight: 20 }, { score: null, max_score: 100, weight: 45 }]), 74.5);
  });
});
