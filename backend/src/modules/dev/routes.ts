import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps } from '../../context.ts';
import { SandboxGateway } from '../../integrations/payments.ts';
import { AppError, notFound } from '../../http/errors.ts';
import { body } from '../../http/helpers.ts';
import { webhookRoutes } from '../fees/routes.ts';

/**
 * Development-only: stand in for the payment provider's checkout page. It signs a webhook for a
 * sandbox payment and delivers it through the REAL webhook handler, so signature checking,
 * settlement, the outbox and receipts are all exercised with no provider account.
 * Only mounted while the sandbox gateway is in use, which config refuses in production.
 */
export function devRoutes(deps: Deps): Hono<AppEnv> | null {
  if (deps.config.NODE_ENV === 'production' || !(deps.payments instanceof SandboxGateway)) return null;
  const gateway = deps.payments;
  const r = new Hono<AppEnv>();
  const webhook = webhookRoutes(deps);

  r.post('/sandbox/complete', async (c) => {
    const b = await body(c, z.object({ reference: z.string().min(1).max(100), outcome: z.enum(['succeeded', 'failed']) }));
    const pay = await deps.db.asService((tx) =>
      tx.query<{ invoice_id: string; amount: string; method: string }>(
        'select invoice_id, amount, method from payments where provider_ref = $1',
        [b.reference],
      ),
    );
    const p = pay.rows[0];
    if (!p) throw notFound('Payment');
    const signed = gateway.sign({
      event: b.outcome === 'succeeded' ? 'payment.succeeded' : 'payment.failed',
      reference: b.reference,
      amount: p.amount,
      method: p.method,
      metadata: { invoice_id: p.invoice_id },
    });
    const res = await webhook.request('/payment', { method: 'POST', headers: signed.headers, body: signed.body });
    if (!res.ok) throw new AppError(res.status, 'sandbox_failed', `The webhook handler answered ${res.status}`);
    return c.body(null, 204);
  });

  return r;
}
