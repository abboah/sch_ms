import { afterEach, beforeEach, describe, expect, test, vi } from "vitest";

const me = (extra = {}) => ({
  id: "p1", full_name: "Akua Asante", role: "guardian", school: { id: "s1", name: "Greenfield", timezone: "Africa/Accra" },
  now: "2026-10-05T08:00:00.000Z", ...extra,
});
const body = (over = {}) => ({ access_token: "access-1", refresh_token: "refresh-1", expires_in: 900, me: me(), ...over });

async function fresh() {
  vi.resetModules();
  return (await import("./session")).session;
}

beforeEach(() => localStorage.clear());
afterEach(() => vi.unstubAllGlobals());

describe("session store", () => {
  test("survives a reload, and signing out removes it", async () => {
    const a = await fresh();
    a.set(body() as never);
    const b = await fresh(); // a new page load
    expect(b.get()?.me.full_name).toBe("Akua Asante");
    b.clear();
    expect((await fresh()).get()).toBeNull();
  });

  test("corrupt storage starts signed out instead of crashing", async () => {
    localStorage.setItem("homeroom.session.v1", "{not json");
    expect((await fresh()).get()).toBeNull();
  });

  test("follows the server's clock, not a wrong device clock", async () => {
    vi.resetModules();
    const m = await import("./session");
    m.session.set(body() as never, Date.parse("2026-01-01T00:00:00Z")); // device says January, server says October
    const drift = m.appNow().getTime() - Date.now();
    expect(drift).toBeGreaterThan(Date.parse("2026-10-05T08:00:00Z") - Date.parse("2026-01-01T00:00:00Z") - 5000);
  });
});

describe("access token refresh", () => {
  test("a token with time left is used as is; one about to expire is refreshed first", async () => {
    const fetchMock = vi.fn(async () => new Response(JSON.stringify(body({ access_token: "access-2", refresh_token: "refresh-2" })), { status: 200 }));
    vi.stubGlobal("fetch", fetchMock);
    const s = await fresh();
    const t0 = 1_000_000;
    s.set(body() as never, t0);
    expect(await s.accessToken(t0 + 60_000)).toBe("access-1");
    expect(fetchMock).not.toHaveBeenCalled();
    expect(await s.accessToken(t0 + 880_000)).toBe("access-2"); // inside the last 30 seconds
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  test("concurrent callers share one refresh (the server rotates tokens, so two would clash)", async () => {
    const fetchMock = vi.fn(async () => {
      await new Promise((r) => setTimeout(r, 20));
      return new Response(JSON.stringify(body({ access_token: "access-2", refresh_token: "refresh-2" })), { status: 200 });
    });
    vi.stubGlobal("fetch", fetchMock);
    const s = await fresh();
    s.set(body() as never, 0);
    await Promise.all([s.refresh(), s.refresh(), s.refresh()]);
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  test("being offline during a refresh does NOT sign the user out", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => { throw new TypeError("Failed to fetch"); }));
    const s = await fresh();
    s.set(body() as never, 0);
    expect(await s.refresh()).toBe(true);
    expect(s.get()).not.toBeNull();
  });

  test("a server error during refresh keeps the session too", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => new Response("{}", { status: 503 })));
    const s = await fresh();
    s.set(body() as never, 0);
    expect(await s.refresh()).toBe(true);
    expect(s.get()).not.toBeNull();
  });

  test("the server saying the refresh token is no longer valid does sign the user out", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => new Response(JSON.stringify({ status: 401, code: "refresh_token_reused" }), { status: 401 })));
    const s = await fresh();
    s.set(body() as never, 0);
    expect(await s.refresh()).toBe(false);
    expect(s.get()).toBeNull();
  });
});
