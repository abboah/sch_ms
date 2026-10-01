/**
 * Unit coverage for the real provider adapters (Paystack, Twilio, Hubtel, FCM). There is no live
 * account to test against in this environment, so these mock `fetch` and check the request this
 * code actually sends and how it parses a response shaped like the provider's published docs.
 * They prove the adapter's own logic (signatures, mappings, error handling), not that the provider
 * still accepts exactly this shape today — confirm that for real before relying on it in production.
 */
import { after, afterEach, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { createLogger } from '../src/lib/logger.ts';
import { hmacHex } from '../src/integrations/payments.ts';
import { PaystackGateway } from '../src/integrations/paystack.ts';
import { TwilioSms, HubtelSms } from '../src/integrations/sms.ts';
import { FcmPush } from '../src/integrations/push.ts';
import { exportPKCS8, generateKeyPair } from 'jose';

const log = createLogger({ level: 'error', sink: () => undefined });
const realFetch = globalThis.fetch;
afterEach(() => { globalThis.fetch = realFetch; });

interface Call { url: string; init?: RequestInit }
function mockFetch(handler: (call: Call) => Response | Promise<Response>): Call[] {
  const calls: Call[] = [];
  globalThis.fetch = (async (input: Parameters<typeof fetch>[0], init?: RequestInit) => {
    const url = typeof input === 'string' ? input : input instanceof URL ? input.toString() : input.url;
    const call = { url, init };
    calls.push(call);
    return handler(call);
  }) as typeof fetch;
  return calls;
}

describe('Paystack gateway', () => {
  const gw = new PaystackGateway('sk_test_abc123', 'http://localhost:5173');

  test('verifyWebhook: correct HMAC-SHA512 of the secret key passes, anything else fails', () => {
    const body = '{"event":"charge.success"}';
    const good = hmacHex('sha512', 'sk_test_abc123', body);
    const headersOk = new Headers({ 'x-paystack-signature': good });
    assert.equal(gw.verifyWebhook(body, headersOk), true);
    const headersBad = new Headers({ 'x-paystack-signature': 'deadbeef'.repeat(16) });
    assert.equal(gw.verifyWebhook(body, headersBad), false);
    assert.equal(gw.verifyWebhook(body, new Headers()), false);
  });

  test('parseWebhook: success/failure, kobo-to-cedis, mobile money bank -> our method enum', () => {
    const success = gw.parseWebhook(JSON.stringify({
      event: 'charge.success',
      data: { reference: 'HR-1', amount: 185000, status: 'success', channel: 'card', metadata: { invoice_id: 'inv-1' } },
    }));
    assert.deepEqual(success, { providerRef: 'HR-1', status: 'succeeded', amount: '1850.00', method: 'card', invoiceId: 'inv-1' });

    const momo = gw.parseWebhook(JSON.stringify({
      event: 'charge.success',
      data: { reference: 'HR-2', amount: 5000, channel: 'mobile_money', authorization: { bank: 'MTN' }, metadata: { invoice_id: 'inv-2' } },
    }));
    assert.equal(momo?.method, 'mtn_momo');
    assert.equal(momo?.amount, '50.00');

    const failed = gw.parseWebhook(JSON.stringify({ event: 'charge.failed', data: { reference: 'HR-3', amount: 100, metadata: { invoice_id: 'inv-3' } } }));
    assert.equal(failed?.status, 'failed');
  });

  test('parseWebhook: an irrelevant event or missing metadata is null, not thrown', () => {
    assert.equal(gw.parseWebhook(JSON.stringify({ event: 'subscription.create', data: {} })), null);
    assert.equal(gw.parseWebhook(JSON.stringify({ event: 'charge.success', data: { reference: 'x', amount: 1 } })), null);
  });

  test('initiate: card hits /transaction/initialize with pesewas and returns the redirect', async () => {
    const calls = mockFetch(() => Response.json({ status: true, data: { authorization_url: 'https://paystack.com/pay/xyz' } }));
    const r = await gw.initiate({
      reference: 'HR-1', amount: '1850.00', currency: 'GHS', method: 'card',
      callbackUrl: 'http://localhost:5173/#/parent/fees', metadata: { invoice_id: 'inv-1' },
    });
    assert.deepEqual(r, { type: 'redirect', redirectUrl: 'https://paystack.com/pay/xyz' });
    assert.equal(calls.length, 1);
    assert.match(calls[0]!.url, /\/transaction\/initialize$/);
    const sent = JSON.parse(calls[0]!.init!.body as string);
    assert.equal(sent.amount, 185000); // GHS -> pesewas
    assert.equal((calls[0]!.init!.headers as Record<string, string>).authorization, 'Bearer sk_test_abc123');
  });

  test('initiate: mobile money hits /charge and maps the method to a provider code', async () => {
    const calls = mockFetch(() => Response.json({ status: true, data: { display_text: 'Approve on your phone' } }));
    const r = await gw.initiate({
      reference: 'HR-2', amount: '50.00', currency: 'GHS', method: 'mtn_momo', phone: '+233240000001',
      callbackUrl: 'http://localhost:5173/#/parent/fees', metadata: { invoice_id: 'inv-2' },
    });
    assert.deepEqual(r, { type: 'prompt', message: 'Approve on your phone' });
    const sent = JSON.parse(calls[0]!.init!.body as string);
    assert.equal(sent.mobile_money.provider, 'mtn');
    assert.equal(sent.mobile_money.phone, '+233240000001');
  });

  test('initiate: a non-ok response throws rather than reporting success', async () => {
    mockFetch(() => Response.json({ status: false, message: 'Invalid key' }, { status: 401 }));
    await assert.rejects(
      gw.initiate({ reference: 'x', amount: '1.00', currency: 'GHS', method: 'card', callbackUrl: 'x', metadata: {} }),
      /Invalid key/,
    );
  });
});

describe('Twilio SMS', () => {
  test('sends a Basic-authed form POST to the account\'s Messages endpoint', async () => {
    const calls = mockFetch(() => new Response('', { status: 201 }));
    const sms = new TwilioSms({ accountSid: 'ACxxx', authToken: 'secret', from: '+15005550006' }, log);
    await sms.send('+233240000001', 'Your code is 123456');
    assert.equal(calls.length, 1);
    assert.match(calls[0]!.url, /\/Accounts\/ACxxx\/Messages\.json$/);
    const headers = calls[0]!.init!.headers as Record<string, string>;
    assert.equal(headers.authorization, `Basic ${Buffer.from('ACxxx:secret').toString('base64')}`);
    const body = new URLSearchParams(calls[0]!.init!.body as string);
    assert.deepEqual([body.get('To'), body.get('From'), body.get('Body')], ['+233240000001', '+15005550006', 'Your code is 123456']);
  });

  test('a non-2xx response raises, it does not fail silently', async () => {
    mockFetch(() => new Response('{"message":"bad number"}', { status: 400 }));
    const sms = new TwilioSms({ accountSid: 'ACxxx', authToken: 'secret', from: '+1' }, log);
    await assert.rejects(sms.send('garbage', 'x'), /Twilio SMS failed with status 400/);
  });
});

describe('Hubtel SMS', () => {
  test('sends credentials and content as query parameters on a GET', async () => {
    const calls = mockFetch(() => new Response('', { status: 200 }));
    const sms = new HubtelSms({ clientId: 'cid', clientSecret: 'csec', from: 'Homeroom' }, log);
    await sms.send('+233240000001', 'Hello');
    const url = new URL(calls[0]!.url);
    assert.equal(url.pathname, '/v1/messages/send');
    assert.deepEqual(
      [url.searchParams.get('clientid'), url.searchParams.get('clientsecret'), url.searchParams.get('from'), url.searchParams.get('to'), url.searchParams.get('content')],
      ['cid', 'csec', 'Homeroom', '+233240000001', 'Hello'],
    );
  });

  test('a non-2xx response raises', async () => {
    mockFetch(() => new Response('error', { status: 500 }));
    const sms = new HubtelSms({ clientId: 'c', clientSecret: 's', from: 'f' }, log);
    await assert.rejects(sms.send('x', 'y'), /Hubtel SMS failed with status 500/);
  });
});

describe('FCM push', () => {
  let privateKeyPem: string;
  before(async () => {
    const { privateKey } = await generateKeyPair('RS256', { extractable: true });
    privateKeyPem = await exportPKCS8(privateKey);
  });

  test('exchanges a signed JWT for a bearer token, then sends per-target and reports dead tokens', async () => {
    let tokenCalls = 0;
    let sendCalls = 0;
    mockFetch(async (call) => {
      if (call.url.includes('oauth2.googleapis.com')) {
        tokenCalls++;
        const body = new URLSearchParams(call.init!.body as string);
        assert.equal(body.get('grant_type'), 'urn:ietf:params:oauth:grant-type:jwt-bearer');
        assert.ok(body.get('assertion'));
        return Response.json({ access_token: 'fake-access-token', expires_in: 3600 });
      }
      sendCalls++;
      const payload = JSON.parse(call.init!.body as string);
      const headers = call.init!.headers as Record<string, string>;
      assert.equal(headers.authorization, 'Bearer fake-access-token');
      if (payload.message.token === 'dead-token') {
        return Response.json({ error: { status: 'UNREGISTERED' } }, { status: 404 });
      }
      return Response.json({ name: 'projects/x/messages/1' });
    });

    const push = new FcmPush({ projectId: 'homeroom-test', clientEmail: 'fcm@homeroom-test.iam.gserviceaccount.com', privateKey: privateKeyPem }, log);
    const r = await push.send(
      [{ token: 'live-token', platform: 'android' }, { token: 'dead-token', platform: 'ios' }],
      { title: 'Homework posted', body: 'Maths, due Friday' },
    );
    assert.equal(tokenCalls, 1); // one token, reused for both sends
    assert.equal(sendCalls, 2);
    assert.deepEqual(r.invalidTokens, ['dead-token']);
  });

  test('an empty target list sends nothing', async () => {
    let called = false;
    mockFetch(() => { called = true; return new Response(''); });
    const push = new FcmPush({ projectId: 'p', clientEmail: 'e', privateKey: privateKeyPem }, log);
    const r = await push.send([], { title: 't', body: 'b' });
    assert.deepEqual(r, { invalidTokens: [] });
    assert.equal(called, false);
  });
});
