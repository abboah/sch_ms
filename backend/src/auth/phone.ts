import { badRequest } from '../http/errors.ts';

/**
 * Normalise a phone number to E.164 so the same number always matches the same account.
 * Accepts "024 410 2231", "0244102231", "+233244102231", "00233244102231".
 */
export function normalizePhone(raw: string, defaultCountryCode: string): string {
  const trimmed = raw.trim();
  const digits = trimmed.replace(/\D/g, '');
  let e164: string;
  if (trimmed.startsWith('+')) e164 = `+${digits}`;
  else if (digits.startsWith('00')) e164 = `+${digits.slice(2)}`;
  else if (digits.startsWith('0')) e164 = `${defaultCountryCode}${digits.slice(1)}`;
  else e164 = `${defaultCountryCode}${digits}`;
  if (!/^\+\d{8,15}$/.test(e164)) throw badRequest('Enter a valid mobile number', 'invalid_phone');
  return e164;
}
