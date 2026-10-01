import type { Logger } from '../lib/logger.ts';

/**
 * Delivery channels as small ports. The console implementations below make the whole
 * system runnable and testable with no provider accounts; real providers (FCM/APNs,
 * Hubtel/Twilio, a transactional email service) are adapters that implement the same
 * interface and are selected in `src/server.ts`. Nothing else changes.
 */

export interface SmsSender {
  send(to: string, text: string): Promise<void>;
}

export interface PushMessage {
  title: string;
  body: string;
  data?: Record<string, string>;
}
export interface PushTarget {
  token: string;
  platform: 'ios' | 'android' | 'web';
}
export interface PushSender {
  /** Returns tokens the provider says are dead, so the caller can delete them. */
  send(targets: PushTarget[], message: PushMessage): Promise<{ invalidTokens: string[] }>;
}

export interface EmailSender {
  send(to: string, subject: string, text: string): Promise<void>;
}

/** Records what would have been sent: logs it and keeps it for tests to inspect. */
export interface Captured<T> {
  sent: T[];
  clear(): void;
}

export function consoleSms(log: Logger): SmsSender & Captured<{ to: string; text: string }> {
  const sent: { to: string; text: string }[] = [];
  return {
    sent,
    clear: () => void (sent.length = 0),
    async send(to, text) {
      sent.push({ to, text });
      log.info('sms (console)', { to, text });
    },
  };
}

export function consolePush(log: Logger): PushSender & Captured<{ targets: PushTarget[]; message: PushMessage }> {
  const sent: { targets: PushTarget[]; message: PushMessage }[] = [];
  return {
    sent,
    clear: () => void (sent.length = 0),
    async send(targets, message) {
      sent.push({ targets, message });
      log.info('push (console)', { tokens: targets.length, title: message.title });
      return { invalidTokens: [] };
    },
  };
}

export function consoleEmail(log: Logger): EmailSender & Captured<{ to: string; subject: string; text: string }> {
  const sent: { to: string; subject: string; text: string }[] = [];
  return {
    sent,
    clear: () => void (sent.length = 0),
    async send(to, subject, text) {
      sent.push({ to, subject, text });
      log.info('email (console)', { to, subject });
    },
  };
}
