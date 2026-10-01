import { SignJWT, importPKCS8 } from 'jose';
import type { Logger } from '../lib/logger.ts';
import type { PushMessage, PushSender, PushTarget } from './channels.ts';

/**
 * Real FCM adapter, HTTP v1 API (the legacy server-key API was shut down by Google in 2024;
 * v1 is the only one left). Same `PushSender` interface as `consolePush`. NOT exercised against
 * a live Firebase project here (no credentials available) — `test/integrations.test.ts` covers
 * the token exchange and per-target send against mocked `fetch`.
 *
 * Needs a Firebase service account: project id, client email and private key (the same three
 * fields in the JSON Firebase gives you for "generate new private key"). v1 has no bulk-send
 * endpoint, so one token is one request; a failed `UNREGISTERED`/`NOT_FOUND` response is the
 * provider's own way of saying "delete this token," same meaning `consolePush`'s result carries.
 */
interface FcmCreds {
  projectId: string;
  clientEmail: string;
  /** PEM, PKCS8. Service-account JSON stores newlines as literal `\n`; callers must un-escape them. */
  privateKey: string;
}

export class FcmPush implements PushSender {
  readonly #creds: FcmCreds;
  readonly #log: Logger;
  #cached: { token: string; expiresAt: number } | null = null;

  constructor(creds: FcmCreds, log: Logger) {
    this.#creds = creds;
    this.#log = log;
  }

  async #accessToken(): Promise<string> {
    const now = Date.now();
    if (this.#cached && this.#cached.expiresAt > now + 60_000) return this.#cached.token;

    const key = await importPKCS8(this.#creds.privateKey, 'RS256');
    const assertion = await new SignJWT({ scope: 'https://www.googleapis.com/auth/firebase.messaging' })
      .setProtectedHeader({ alg: 'RS256' })
      .setIssuer(this.#creds.clientEmail)
      .setSubject(this.#creds.clientEmail)
      .setAudience('https://oauth2.googleapis.com/token')
      .setIssuedAt()
      .setExpirationTime('1h')
      .sign(key);

    const res = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion }),
    });
    const body = (await res.json()) as { access_token?: string; expires_in?: number; error?: string };
    if (!res.ok || !body.access_token) throw new Error(`FCM token exchange failed: ${body.error ?? res.status}`);
    this.#cached = { token: body.access_token, expiresAt: now + (body.expires_in ?? 3600) * 1000 };
    return body.access_token;
  }

  async send(targets: PushTarget[], message: PushMessage): Promise<{ invalidTokens: string[] }> {
    if (targets.length === 0) return { invalidTokens: [] };
    const accessToken = await this.#accessToken();
    const invalidTokens: string[] = [];
    await Promise.all(
      targets.map(async (t) => {
        const res = await fetch(`https://fcm.googleapis.com/v1/projects/${this.#creds.projectId}/messages:send`, {
          method: 'POST',
          headers: { authorization: `Bearer ${accessToken}`, 'content-type': 'application/json' },
          body: JSON.stringify({ message: { token: t.token, notification: { title: message.title, body: message.body }, data: message.data ?? {} } }),
        });
        if (!res.ok) {
          const err = (await res.json().catch(() => null)) as { error?: { status?: string } } | null;
          if (err?.error?.status === 'UNREGISTERED' || err?.error?.status === 'NOT_FOUND') invalidTokens.push(t.token);
          else this.#log.error('fcm send failed', { status: res.status, platform: t.platform, error: err?.error });
        }
      }),
    );
    return { invalidTokens };
  }
}
