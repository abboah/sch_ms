import type { Config } from './config.ts';
import type { Deps } from './context.ts';
import { createTokenService } from './auth/tokens.ts';
import { migrate } from './db/migrate.ts';
import { openPglite } from './db/pglite.ts';
import { openPostgres } from './db/postgres.ts';
import type { Db } from './db/types.ts';
import { consoleEmail, consolePush, consoleSms, type PushSender, type SmsSender } from './integrations/channels.ts';
import { SandboxGateway, type PaymentGateway } from './integrations/payments.ts';
import { PaystackGateway } from './integrations/paystack.ts';
import { FcmPush } from './integrations/push.ts';
import { HubtelSms, TwilioSms } from './integrations/sms.ts';
import { fixedClock, systemClock } from './lib/clock.ts';
import { createLogger, type Logger } from './lib/logger.ts';

function buildSms(config: Config, log: Logger): SmsSender {
  if (config.SMS_PROVIDER === 'twilio') {
    return new TwilioSms({ accountSid: config.TWILIO_ACCOUNT_SID!, authToken: config.TWILIO_AUTH_TOKEN!, from: config.TWILIO_FROM! }, log);
  }
  if (config.SMS_PROVIDER === 'hubtel') {
    return new HubtelSms({ clientId: config.HUBTEL_CLIENT_ID!, clientSecret: config.HUBTEL_CLIENT_SECRET!, from: config.HUBTEL_FROM! }, log);
  }
  return consoleSms(log);
}

function buildPush(config: Config, log: Logger): PushSender {
  if (config.PUSH_PROVIDER === 'fcm') {
    return new FcmPush(
      { projectId: config.FCM_PROJECT_ID!, clientEmail: config.FCM_CLIENT_EMAIL!, privateKey: config.FCM_PRIVATE_KEY!.replace(/\\n/g, '\n') },
      log,
    );
  }
  return consolePush(log);
}

function buildPaymentGateway(config: Config): PaymentGateway {
  return config.PAYMENT_GATEWAY === 'paystack'
    ? new PaystackGateway(config.PAYSTACK_SECRET_KEY!, config.PUBLIC_WEB_URL)
    : new SandboxGateway(config.PAYMENT_WEBHOOK_SECRET, config.PUBLIC_WEB_URL);
}

export async function openDb(config: Config, log: Logger): Promise<Db> {
  if (config.DATABASE_URL) {
    log.info('database: postgres');
    return openPostgres(config.DATABASE_URL);
  }
  const dir = config.NODE_ENV === 'test' ? '' : config.PGLITE_DIR;
  log.info('database: embedded pglite', { dataDir: dir || '(memory)' });
  return openPglite(dir ? { dataDir: dir } : {});
}

/**
 * Assemble real dependencies from configuration and bring the schema up to date.
 * Any dependency can be overridden (tests do this with a fixed clock, in-memory db, captured channels).
 */
export async function createDeps(config: Config, overrides: Partial<Deps> = {}): Promise<Deps> {
  const log = overrides.log ?? createLogger({ level: config.LOG_LEVEL });
  const db = overrides.db ?? (await openDb(config, log));
  const clock = overrides.clock ?? (config.DEMO_NOW && config.NODE_ENV !== 'production' ? fixedClock(config.DEMO_NOW) : systemClock);
  if (config.DEMO_NOW && config.NODE_ENV === 'production') log.warn('DEMO_NOW is ignored in production');
  const migrated = await migrate(db);
  if (migrated.applied.length) log.info('migrations applied', { migrations: migrated.applied });

  return {
    config,
    db,
    log,
    clock,
    tokens: overrides.tokens ?? createTokenService(config.JWT_SECRET, clock.now),
    sms: overrides.sms ?? buildSms(config, log),
    push: overrides.push ?? buildPush(config, log),
    email: overrides.email ?? consoleEmail(log),
    payments: overrides.payments ?? buildPaymentGateway(config),
  };
}
