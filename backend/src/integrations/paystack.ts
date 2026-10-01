import { hmacHex, safeEqualHex, type InitiateInput, type InitiateResult, type PayMethod, type PaymentGateway, type WebhookEvent } from './payments.ts';

/**
 * Real Paystack adapter. Same interface as SandboxGateway, so nothing else in the app changes.
 *
 * NOT exercised against a live Paystack account in this codebase (no credentials available here) —
 * `test/integrations.test.ts` covers signature verification and request/response shaping against
 * mocked `fetch`, built from Paystack's published API docs as of writing. Before relying on this in
 * production: run one real transaction against Paystack's test keys and confirm the webhook payload
 * shape (`data.channel`, `data.authorization`) still matches what `parseWebhook` expects below —
 * gateways change field names between API versions more often than their core behaviour.
 */

const API = 'https://api.paystack.co';

/** Paystack's mobile money channel does not say "MTN" or "Telecel" directly; it reports a bank code. */
const MOMO_BANK_TO_METHOD: Record<string, PayMethod> = {
  mtn: 'mtn_momo',
  MTN: 'mtn_momo',
  vod: 'telecel_cash',
  VOD: 'telecel_cash',
  vodafone: 'telecel_cash',
  telecel: 'telecel_cash',
};

export class PaystackGateway implements PaymentGateway {
  readonly name = 'paystack';
  readonly #secretKey: string;
  readonly #webUrl: string;

  constructor(secretKey: string, webUrl: string) {
    this.#secretKey = secretKey;
    this.#webUrl = webUrl;
  }

  async initiate(input: InitiateInput): Promise<InitiateResult> {
    if (input.method === 'card') {
      const res = await fetch(`${API}/transaction/initialize`, {
        method: 'POST',
        headers: { authorization: `Bearer ${this.#secretKey}`, 'content-type': 'application/json' },
        body: JSON.stringify({
          reference: input.reference,
          amount: Math.round(Number(input.amount) * 100), // GHS -> pesewas
          currency: input.currency,
          email: input.email ?? `${input.reference}@invoice.homeroom.app`, // Paystack requires an email even for card
          callback_url: input.callbackUrl,
          metadata: input.metadata,
        }),
      });
      const body = (await res.json()) as { status: boolean; message?: string; data?: { authorization_url: string } };
      if (!res.ok || !body.status || !body.data) throw new Error(`Paystack initialize failed: ${body.message ?? res.status}`);
      return { type: 'redirect', redirectUrl: body.data.authorization_url };
    }

    // Mobile money: the Charge API starts the push/USSD prompt directly, no redirect.
    const provider = input.method === 'mtn_momo' ? 'mtn' : 'vod';
    const res = await fetch(`${API}/charge`, {
      method: 'POST',
      headers: { authorization: `Bearer ${this.#secretKey}`, 'content-type': 'application/json' },
      body: JSON.stringify({
        reference: input.reference,
        amount: Math.round(Number(input.amount) * 100),
        currency: input.currency,
        email: input.email ?? `${input.reference}@invoice.homeroom.app`,
        mobile_money: { phone: input.phone, provider },
        metadata: input.metadata,
      }),
    });
    const body = (await res.json()) as { status: boolean; message?: string; data?: { display_text?: string } };
    if (!res.ok || !body.status) throw new Error(`Paystack charge failed: ${body.message ?? res.status}`);
    return { type: 'prompt', message: body.data?.display_text ?? `Approve the request on ${input.phone ?? 'your phone'}` };
  }

  /** Paystack signs the raw body with HMAC-SHA512 of the secret key, in `x-paystack-signature`. */
  verifyWebhook(rawBody: string, headers: Headers): boolean {
    const sig = headers.get('x-paystack-signature');
    return !!sig && safeEqualHex(sig, hmacHex('sha512', this.#secretKey, rawBody));
  }

  parseWebhook(rawBody: string): WebhookEvent | null {
    const e = JSON.parse(rawBody) as {
      event?: string;
      data?: {
        reference?: string; amount?: number; status?: string; channel?: string;
        authorization?: { bank?: string }; metadata?: { invoice_id?: string } | string;
      };
    };
    const status =
      e.event === 'charge.success' ? 'succeeded' : e.event === 'charge.failed' ? 'failed' : null;
    const d = e.data;
    if (!status || !d?.reference || d.amount == null) return null;
    // Paystack echoes metadata back; a plain string here means it wasn't ours to act on.
    const metadata = typeof d.metadata === 'object' ? d.metadata : undefined;
    const invoiceId = metadata?.invoice_id;
    if (!invoiceId) return null;
    const method: PayMethod =
      d.channel === 'mobile_money' ? (MOMO_BANK_TO_METHOD[d.authorization?.bank ?? ''] ?? 'mtn_momo') : 'card';
    return {
      providerRef: d.reference,
      status,
      amount: (d.amount / 100).toFixed(2), // pesewas -> GHS
      method,
      invoiceId,
    };
  }
}
