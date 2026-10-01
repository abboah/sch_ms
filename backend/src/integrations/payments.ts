import { createHmac, timingSafeEqual } from 'node:crypto';

/**
 * Payment gateway port. The invoice ledger never trusts the client: a payment is only
 * settled by a signed webhook that the gateway calls, verified here.
 *
 * `SandboxGateway` runs locally with no account: it signs webhooks with a shared secret
 * so the full flow (start, webhook, settle, receipt) works end to end in development and
 * in tests. A Paystack adapter implements the same interface (see paystack.ts).
 */

export type PayMethod = 'card' | 'mtn_momo' | 'telecel_cash';

export interface InitiateInput {
  reference: string;
  /** Decimal string, e.g. "600.00". */
  amount: string;
  currency: 'GHS';
  method: PayMethod;
  phone?: string | undefined;
  email?: string | undefined;
  callbackUrl: string;
  metadata: Record<string, string>;
}

export type InitiateResult =
  | { type: 'redirect'; redirectUrl: string }
  | { type: 'prompt'; message: string };

export interface WebhookEvent {
  providerRef: string;
  status: 'succeeded' | 'failed' | 'pending';
  /** Decimal string as confirmed by the gateway. */
  amount: string;
  method: PayMethod | 'manual';
  invoiceId: string;
}

export interface PaymentGateway {
  readonly name: string;
  initiate(input: InitiateInput): Promise<InitiateResult>;
  /** True only if `rawBody` was signed by the gateway. Must use constant-time comparison. */
  verifyWebhook(rawBody: string, headers: Headers): boolean;
  /** Null when the event is valid but irrelevant (e.g. a refund notification we ignore). */
  parseWebhook(rawBody: string): WebhookEvent | null;
}

export function hmacHex(algo: 'sha256' | 'sha512', secret: string, body: string): string {
  return createHmac(algo, secret).update(body).digest('hex');
}

export function safeEqualHex(a: string, b: string): boolean {
  const x = Buffer.from(a, 'utf8');
  const y = Buffer.from(b, 'utf8');
  return x.length === y.length && timingSafeEqual(x, y);
}

export class SandboxGateway implements PaymentGateway {
  readonly name = 'sandbox';
  readonly #secret: string;
  readonly #webUrl: string;
  constructor(secret: string, webUrl: string) {
    this.#secret = secret;
    this.#webUrl = webUrl;
  }

  async initiate(input: InitiateInput): Promise<InitiateResult> {
    if (input.method === 'card') {
      const url = `${this.#webUrl}/#/parent/pay/sandbox?ref=${encodeURIComponent(input.reference)}`;
      return { type: 'redirect', redirectUrl: url };
    }
    return {
      type: 'prompt',
      message: `Approve the GH¢${input.amount} request on ${input.phone ?? 'your phone'} (sandbox: no real charge)`,
    };
  }

  verifyWebhook(rawBody: string, headers: Headers): boolean {
    const sig = headers.get('x-signature');
    return !!sig && safeEqualHex(sig, hmacHex('sha256', this.#secret, rawBody));
  }

  parseWebhook(rawBody: string): WebhookEvent | null {
    const e = JSON.parse(rawBody) as {
      event?: string;
      reference?: string;
      amount?: string;
      method?: PayMethod;
      metadata?: { invoice_id?: string };
    };
    const status =
      e.event === 'payment.succeeded' ? 'succeeded' : e.event === 'payment.failed' ? 'failed' : null;
    if (!status || !e.reference || !e.amount || !e.metadata?.invoice_id) return null;
    return {
      providerRef: e.reference,
      status,
      amount: e.amount,
      method: e.method ?? 'card',
      invoiceId: e.metadata.invoice_id,
    };
  }

  /** Test/dev helper: produce a signed webhook as the gateway would send it. */
  sign(body: object): { body: string; headers: Record<string, string> } {
    const raw = JSON.stringify(body);
    return { body: raw, headers: { 'content-type': 'application/json', 'x-signature': hmacHex('sha256', this.#secret, raw) } };
  }
}
