import { z } from 'zod';

/**
 * Every setting the server reads, in one place, validated at boot. A bad or missing
 * value fails fast with a readable message instead of surfacing as a runtime bug.
 */
const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),

  /** Postgres connection string. When unset, an embedded PGlite database is used. */
  DATABASE_URL: z.string().optional(),
  /** Where PGlite persists data in development. Empty string = in-memory. */
  PGLITE_DIR: z.string().default('.data/pglite'),

  JWT_SECRET: z.string().min(32).optional(),
  ACCESS_TOKEN_TTL_SECONDS: z.coerce.number().int().positive().default(15 * 60),
  REFRESH_TOKEN_TTL_SECONDS: z.coerce.number().int().positive().default(30 * 24 * 3600),

  /** Comma-separated origins allowed by CORS, or * in development. */
  CORS_ORIGINS: z.string().default('*'),

  PAYMENT_GATEWAY: z.enum(['sandbox', 'paystack']).default('sandbox'),
  PAYMENT_WEBHOOK_SECRET: z.string().min(16).optional(),
  PAYSTACK_SECRET_KEY: z.string().optional(),
  /** Explicit opt-in to run production with fake payments (MVP/evaluation deploys without a Paystack account yet). */
  ALLOW_SANDBOX_PAYMENTS: z
    .enum(['true', 'false'])
    .default('false')
    .transform((v) => v === 'true'),
  /** Base URL the gateway redirects the parent back to after checkout. */
  PUBLIC_WEB_URL: z.string().url().default('http://localhost:5173'),

  /** Console just logs what would have been sent (default dev/test); a real provider is opt-in. */
  SMS_PROVIDER: z.enum(['console', 'twilio', 'hubtel']).default('console'),
  TWILIO_ACCOUNT_SID: z.string().optional(),
  TWILIO_AUTH_TOKEN: z.string().optional(),
  TWILIO_FROM: z.string().optional(),
  HUBTEL_CLIENT_ID: z.string().optional(),
  HUBTEL_CLIENT_SECRET: z.string().optional(),
  HUBTEL_FROM: z.string().optional(),

  PUSH_PROVIDER: z.enum(['console', 'fcm']).default('console'),
  FCM_PROJECT_ID: z.string().optional(),
  FCM_CLIENT_EMAIL: z.string().optional(),
  /** PEM private key from the Firebase service account JSON; literal `\n` is unescaped before use. */
  FCM_PRIVATE_KEY: z.string().optional(),

  /** Seed the demo school on first boot of an empty database (development only). */
  SEED_DEMO: z
    .enum(['true', 'false'])
    .default('false')
    .transform((v) => v === 'true'),
  DEMO_PASSWORD: z.string().default('password123'),
  /**
   * Development only: pretend "now" is this instant, so the demo school's dates (Term 1 2026, marks for
   * 28 Sep to 2 Oct) line up with what the screens show. Ignored in production.
   */
  DEMO_NOW: z.iso.datetime().optional(),

  /** Prepended to phone numbers entered without a country code (a leading 0 is dropped). */
  DEFAULT_COUNTRY_CODE: z.string().regex(/^\+\d{1,3}$/).default('+233'),
  /** Max sign-in style requests per client per minute (0 disables). */
  AUTH_RATE_LIMIT_PER_MINUTE: z.coerce.number().int().min(0).default(20),
});

export type Config = z.infer<typeof schema> & { JWT_SECRET: string; PAYMENT_WEBHOOK_SECRET: string };

const DEV_JWT_SECRET = 'dev-only-secret-do-not-use-in-production-0000';
const DEV_WEBHOOK_SECRET = 'dev-only-webhook-secret';

export function loadConfig(env: Record<string, string | undefined> = process.env): Config {
  const parsed = schema.safeParse(env);
  if (!parsed.success) {
    const lines = parsed.error.issues.map((i) => `  ${i.path.join('.')}: ${i.message}`);
    throw new Error(`Invalid configuration:\n${lines.join('\n')}`);
  }
  const c = parsed.data;
  if (c.SMS_PROVIDER === 'twilio' && !(c.TWILIO_ACCOUNT_SID && c.TWILIO_AUTH_TOKEN && c.TWILIO_FROM)) {
    throw new Error('SMS_PROVIDER=twilio needs TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN and TWILIO_FROM');
  }
  if (c.SMS_PROVIDER === 'hubtel' && !(c.HUBTEL_CLIENT_ID && c.HUBTEL_CLIENT_SECRET && c.HUBTEL_FROM)) {
    throw new Error('SMS_PROVIDER=hubtel needs HUBTEL_CLIENT_ID, HUBTEL_CLIENT_SECRET and HUBTEL_FROM');
  }
  if (c.PUSH_PROVIDER === 'fcm' && !(c.FCM_PROJECT_ID && c.FCM_CLIENT_EMAIL && c.FCM_PRIVATE_KEY)) {
    throw new Error('PUSH_PROVIDER=fcm needs FCM_PROJECT_ID, FCM_CLIENT_EMAIL and FCM_PRIVATE_KEY');
  }
  if (c.NODE_ENV === 'production') {
    const missing = [
      !c.JWT_SECRET && 'JWT_SECRET',
      !c.DATABASE_URL && 'DATABASE_URL',
      !c.PAYMENT_WEBHOOK_SECRET && 'PAYMENT_WEBHOOK_SECRET',
      c.PAYMENT_GATEWAY === 'paystack' && !c.PAYSTACK_SECRET_KEY && 'PAYSTACK_SECRET_KEY',
    ].filter(Boolean);
    if (missing.length) throw new Error(`Missing required production settings: ${missing.join(', ')}`);
    if (c.CORS_ORIGINS === '*') throw new Error('CORS_ORIGINS must list explicit origins in production');
    if (c.PAYMENT_GATEWAY === 'sandbox' && !c.ALLOW_SANDBOX_PAYMENTS) {
      throw new Error(
        'PAYMENT_GATEWAY=sandbox is not allowed in production unless ALLOW_SANDBOX_PAYMENTS=true ' +
          '(MVP/evaluation only — no real money moves until PAYMENT_GATEWAY=paystack is configured)',
      );
    }
  }
  return {
    ...c,
    JWT_SECRET: c.JWT_SECRET ?? DEV_JWT_SECRET,
    PAYMENT_WEBHOOK_SECRET: c.PAYMENT_WEBHOOK_SECRET ?? DEV_WEBHOOK_SECRET,
  };
}
