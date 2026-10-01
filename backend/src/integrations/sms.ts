import type { Logger } from '../lib/logger.ts';
import type { SmsSender } from './channels.ts';

/**
 * Real SMS adapters for the two providers common in Ghana. Same `SmsSender` interface as
 * `consoleSms`, so nothing else changes. NOT exercised against a live account here (no
 * credentials available) — `test/integrations.test.ts` covers request shaping against mocked
 * `fetch`. Confirm against each provider's current docs before relying on this in production.
 */

export class TwilioSms implements SmsSender {
  readonly #accountSid: string;
  readonly #authToken: string;
  readonly #from: string;
  readonly #log: Logger;

  constructor(opts: { accountSid: string; authToken: string; from: string }, log: Logger) {
    this.#accountSid = opts.accountSid;
    this.#authToken = opts.authToken;
    this.#from = opts.from;
    this.#log = log;
  }

  async send(to: string, text: string): Promise<void> {
    const auth = Buffer.from(`${this.#accountSid}:${this.#authToken}`).toString('base64');
    const res = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${this.#accountSid}/Messages.json`, {
      method: 'POST',
      headers: { authorization: `Basic ${auth}`, 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ To: to, From: this.#from, Body: text }),
    });
    if (!res.ok) {
      const detail = await res.text().catch(() => '');
      this.#log.error('twilio sms failed', { status: res.status, to, detail: detail.slice(0, 500) });
      throw new Error(`Twilio SMS failed with status ${res.status}`);
    }
  }
}

export class HubtelSms implements SmsSender {
  readonly #clientId: string;
  readonly #clientSecret: string;
  readonly #from: string;
  readonly #log: Logger;

  constructor(opts: { clientId: string; clientSecret: string; from: string }, log: Logger) {
    this.#clientId = opts.clientId;
    this.#clientSecret = opts.clientSecret;
    this.#from = opts.from;
    this.#log = log;
  }

  async send(to: string, text: string): Promise<void> {
    const url = new URL('https://sms.hubtel.com/v1/messages/send');
    url.searchParams.set('clientid', this.#clientId);
    url.searchParams.set('clientsecret', this.#clientSecret);
    url.searchParams.set('from', this.#from);
    url.searchParams.set('to', to);
    url.searchParams.set('content', text);
    const res = await fetch(url, { method: 'GET' });
    if (!res.ok) {
      const detail = await res.text().catch(() => '');
      this.#log.error('hubtel sms failed', { status: res.status, to, detail: detail.slice(0, 500) });
      throw new Error(`Hubtel SMS failed with status ${res.status}`);
    }
  }
}
