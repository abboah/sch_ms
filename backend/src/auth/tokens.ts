import { createHash, randomBytes } from 'node:crypto';
import { SignJWT, jwtVerify, errors as joseErrors } from 'jose';
import { unauthorized } from '../http/errors.ts';

const ISSUER = 'homeroom';
const AUDIENCE = 'homeroom-api';

export type Role = 'admin' | 'teacher' | 'guardian' | 'student';

export interface AccessClaims {
  personId: string;
  role: Role;
  schoolId: string;
  /** Refresh-token family: lets sign-out revoke exactly this session. */
  sessionId: string;
}

export interface TokenService {
  signAccess(claims: AccessClaims, ttlSeconds: number): Promise<string>;
  verifyAccess(token: string): Promise<AccessClaims>;
  signSelection(accountId: string, ttlSeconds: number): Promise<string>;
  verifySelection(token: string): Promise<{ accountId: string }>;
}

export function createTokenService(secret: string, now: () => Date): TokenService {
  const key = new TextEncoder().encode(secret);

  const sign = (claims: Record<string, unknown>, sub: string, typ: string, ttl: number) => {
    const iat = Math.floor(now().getTime() / 1000);
    return new SignJWT({ ...claims, typ })
      .setProtectedHeader({ alg: 'HS256' })
      .setSubject(sub)
      .setIssuer(ISSUER)
      .setAudience(AUDIENCE)
      .setIssuedAt(iat)
      .setExpirationTime(iat + ttl)
      .sign(key);
  };

  const verify = async (token: string, typ: string) => {
    try {
      const { payload } = await jwtVerify(token, key, {
        issuer: ISSUER,
        audience: AUDIENCE,
        algorithms: ['HS256'],
        currentDate: now(),
      });
      if (payload['typ'] !== typ || !payload.sub) throw unauthorized('Wrong token type', 'invalid_token');
      return payload;
    } catch (err) {
      if (err instanceof joseErrors.JWTExpired) throw unauthorized('Token expired', 'token_expired');
      if (err instanceof Error && err.name === 'AppError') throw err;
      throw unauthorized('Invalid token', 'invalid_token');
    }
  };

  return {
    signAccess: (c, ttl) => sign({ role: c.role, sch: c.schoolId, sid: c.sessionId }, c.personId, 'access', ttl),
    async verifyAccess(token) {
      const p = await verify(token, 'access');
      return {
        personId: p.sub as string,
        role: p['role'] as Role,
        schoolId: p['sch'] as string,
        sessionId: p['sid'] as string,
      };
    },
    signSelection: (accountId, ttl) => sign({}, accountId, 'select', ttl),
    async verifySelection(token) {
      const p = await verify(token, 'select');
      return { accountId: p.sub as string };
    },
  };
}

/** Opaque, unguessable, single-use. Only the hash is stored. */
export function newRefreshToken(): { token: string; hash: string } {
  const token = randomBytes(32).toString('base64url');
  return { token, hash: hashToken(token) };
}

export function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}
