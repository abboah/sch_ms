import { beforeEach, describe, expect, test, vi } from "vitest";

const write = vi.fn();
vi.mock("../api/client", () => ({ rawWrite: (...a: unknown[]) => write(...a) }));

const ok = (body: unknown = {}) => new Response(JSON.stringify(body), { status: 200 });
const refused = (status = 403, detail = "This term is closed") => new Response(JSON.stringify({ status, title: "Forbidden", detail, code: "term_closed" }), { status });
const offline = () => { throw new TypeError("Failed to fetch"); };
const job = (label: string, body: unknown = {}) => ({ method: "PUT" as const, path: "/class_sections/s1/attendance", body, label });

async function fresh() {
  vi.resetModules();
  return (await import("./queue")).outbox;
}

beforeEach(() => {
  localStorage.clear();
  write.mockReset();
});

describe("outbox", () => {
  test("a write that reaches the server is sent, not stored, and returns the per-entry results", async () => {
    write.mockResolvedValue(ok({ applied: 3, rejected: 0 }));
    const q = await fresh();
    const r = await q.submit(job("Register"));
    expect(r).toEqual({ status: "sent", body: { applied: 3, rejected: 0 } });
    expect(q.count()).toBe(0);
  });

  test("offline: the write is kept on the device, and survives a reload", async () => {
    write.mockImplementation(offline);
    const q = await fresh();
    expect((await q.submit(job("Register 6A"))).status).toBe("queued");
    expect(q.count()).toBe(1);
    expect((await fresh()).count()).toBe(1); // new page load reads it back
  });

  test("a server error is treated like being offline: keep it and retry", async () => {
    write.mockResolvedValue(new Response("{}", { status: 503 }));
    const q = await fresh();
    expect((await q.submit(job("Register"))).status).toBe("queued");
  });

  test("a refusal (4xx) is reported, not queued: retrying could never help", async () => {
    write.mockResolvedValue(refused());
    const q = await fresh();
    const r = await q.submit(job("Register"));
    expect(r.status).toBe("rejected");
    expect(q.count()).toBe(0);
  });

  test("once the network is back, queued writes replay in order and the queue empties", async () => {
    write.mockImplementation(offline);
    const q = await fresh();
    await q.submit(job("first", { n: 1 }));
    await q.submit(job("second", { n: 2 }));
    write.mockReset();
    write.mockResolvedValue(ok());
    await q.flush();
    expect(q.count()).toBe(0);
    expect(write.mock.calls.map((c) => (c[2] as { n: number }).n)).toEqual([1, 2]);
  });

  test("replaying reuses each write's Idempotency-Key, so a half-finished attempt cannot apply twice", async () => {
    write.mockImplementation(offline);
    const q = await fresh();
    await q.submit(job("Register", { n: 1 }));
    const firstKey = write.mock.calls[0]![3];
    write.mockReset();
    write.mockResolvedValue(ok());
    await q.flush();
    expect(write.mock.calls[0]![3]).toBe(firstKey);
  });

  test("replay stops at the first write that cannot be delivered, keeping order", async () => {
    write.mockImplementation(offline);
    const q = await fresh();
    await q.submit(job("one"));
    await q.submit(job("two"));
    write.mockReset();
    write.mockResolvedValueOnce(ok()).mockImplementation(offline);
    await q.flush();
    expect(q.count()).toBe(1);
    expect(q.list()[0]!.label).toBe("two");
  });

  test("a write the server refuses on replay is dropped, reported once, and does not block the ones behind it", async () => {
    write.mockImplementation(offline);
    const q = await fresh();
    await q.submit(job("Register for 5A", { n: 1 }));
    await q.submit(job("Register for 6A", { n: 2 }));
    write.mockReset();
    write.mockResolvedValueOnce(refused(403, "This term is closed")).mockResolvedValue(ok());
    await q.flush();
    expect(q.count()).toBe(0);
    const dropped = q.takeDropped();
    expect(dropped).toEqual([{ label: "Register for 5A", reason: "This term is closed" }]);
    expect(q.takeDropped()).toEqual([]); // shown once
  });

  test("a signed-out session keeps everything for after the next sign-in", async () => {
    write.mockImplementation(offline);
    const q = await fresh();
    await q.submit(job("Register"));
    write.mockReset();
    write.mockResolvedValue(new Response("{}", { status: 401 }));
    await q.flush();
    expect(q.count()).toBe(1);
  });
});
