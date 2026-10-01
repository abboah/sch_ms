import type { components } from "./schema";

export type Problem = components["schemas"]["Problem"];

/** The API answers every failure with a problem document; openapi-fetch hands it back as the error value. */
export function problemOf(e: unknown): Problem | null {
  if (e && typeof e === "object" && "status" in e && "code" in e && typeof (e as Problem).status === "number") return e as Problem;
  return null;
}

/** fetch() rejects with a TypeError when the network is down, the server is unreachable or CORS fails. */
export const isNetworkError = (e: unknown): boolean => e instanceof TypeError;

export const isUnauthorized = (e: unknown): boolean => problemOf(e)?.status === 401;

/** A sentence safe to show a person. Never a stack trace or a bare status code. */
export function errorMessage(e: unknown): string {
  if (isNetworkError(e)) return "You appear to be offline, or the server cannot be reached.";
  const p = problemOf(e);
  if (!p) return "Something went wrong. Please try again.";
  if (p.status >= 500) return "The server had a problem. Nothing you did is lost; please try again in a moment.";
  if (p.errors?.length) return p.errors.map((x) => `${x.field}: ${x.message}`).join(". ");
  return p.detail ?? p.title;
}

/** Reference to quote when asking for help: the id in the response's X-Request-Id, matched in the server logs. */
export const requestIdOf = (e: unknown): string | undefined => problemOf(e)?.request_id;
