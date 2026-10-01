import createClient from "openapi-fetch";
import createQueryClient from "openapi-react-query";
import { QueryClient } from "@tanstack/react-query";
import type { paths } from "./schema";
import { API_BASE, session } from "./session";
import { isNetworkError, problemOf } from "./errors";

/**
 * Every API call goes through here: it attaches the access token, refreshes it when needed, and
 * retries once if the server says the token just expired. GETs are retried by the query client when
 * the network drops; writes that must survive offline go through offline/queue.ts.
 */
async function authedFetch(input: Request): Promise<Response> {
  const spare = input.clone(); // the body can only be read once; keep a copy for the retry
  const token = await session.accessToken();
  if (token) input.headers.set("authorization", `Bearer ${token}`);
  let res = await fetch(input);

  if (res.status === 401 && session.hasRefresh() && (await session.refresh())) {
    const fresh = session.get();
    if (fresh) spare.headers.set("authorization", `Bearer ${fresh.accessToken}`);
    res = await fetch(spare);
  }
  return res;
}

export const api = createClient<paths>({ baseUrl: API_BASE, fetch: authedFetch });
export const $api = createQueryClient(api);

/** Network failures and 5xx are worth retrying with backoff; a 4xx means "no", and asking again will not change it. */
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 15_000,
      retry: (count, error) => count < 5 && (isNetworkError(error) || (problemOf(error)?.status ?? 0) >= 500),
      retryDelay: (attempt) => Math.min(1000 * 2 ** attempt, 30_000),
      refetchOnReconnect: true,
      refetchOnWindowFocus: true,
    },
    mutations: { retry: false },
  },
});

/** A raw authenticated request with an Idempotency-Key, for queued offline writes whose path is already concrete. */
export async function rawWrite(method: "PUT" | "PATCH" | "POST", path: string, body: unknown, key: string): Promise<Response> {
  const req = new Request(`${API_BASE}${path}`, {
    method,
    headers: { "content-type": "application/json", "idempotency-key": key },
    body: JSON.stringify(body),
  });
  return authedFetch(req);
}
