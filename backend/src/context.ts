import type { Config } from './config.ts';
import type { Db, Tx } from './db/types.ts';
import type { Logger } from './lib/logger.ts';
import type { Clock } from './lib/clock.ts';
import type { TokenService, AccessClaims } from './auth/tokens.ts';
import type { EmailSender, PushSender, SmsSender } from './integrations/channels.ts';
import type { PaymentGateway } from './integrations/payments.ts';

/** Everything the server needs from the outside world, injected so tests can swap any of it. */
export interface Deps {
  config: Config;
  db: Db;
  log: Logger;
  clock: Clock;
  tokens: TokenService;
  sms: SmsSender;
  push: PushSender;
  email: EmailSender;
  payments: PaymentGateway;
}

/** Hono variables available to handlers. */
export interface AppEnv {
  Variables: {
    requestId: string;
    log: Logger;
    auth: AccessClaims;
  };
}

export type { Tx };
