# Architecture and decisions

Written while you were away. Every choice here is reversible; the "Why" is there so you can judge it quickly.

## Shape

```
sch_ms/
  backend/    Postgres schema + RLS, TypeScript API (Hono), jobs, tests, openapi.yaml (the contract)
  web/        Vite + React SPA (the Figma Make export, wired to the API)
  mobile/     Flutter app (teacher + parent), wired to the same API
  docs/       design package, this file
```

One contract (`backend/openapi.yaml`) feeds all three: the API validates against it in tests, the web app gets generated TypeScript types from it, Flutter gets a generated client from it. Drift shows up as a compile error or a failing contract test, not a runtime surprise.

## Principles
1. **The database is the permission engine.** The API runs every user request as the non-superuser `app_user` role with `app.person_id` set, so Postgres RLS (tested: `backend/test/rls.test.ts`) is the only place a rule lives. The API adds no second, divergent copy of the rules. Service-role access is limited to: authentication, payment webhooks, the notification worker, idempotency bookkeeping.
2. **Side effects go through a transactional outbox.** Database triggers enqueue `notification_outbox` rows in the same transaction as the change (attendance marked, homework posted, announcement published, message sent, payment settled). A worker expands them into in-app notifications and push / SMS / email deliveries. A crash cannot lose or duplicate a notification, and adding a channel touches one file.
3. **Integrations sit behind small interfaces** (`PaymentGateway`, `SmsSender`, `PushSender`, `EmailSender`) with a working local implementation, so everything runs and is testable with no external accounts. Real providers (Paystack, Hubtel, FCM) are adapters to write, not redesigns.
4. **Append-only migrations.** Each migration is a feature slice (tables + functions + policies + grants). 001-003 are the original layered baseline; from 004 on, never edit an applied migration.
5. **Debuggable by default.** Every request gets an id (`X-Request-Id`, returned and logged); logs are one JSON object per line; errors are RFC 9457 problem documents with a stable `code`; the database errors that matter (RLS denial, constraint) map to specific codes; `/healthz` (liveness) and `/readyz` (database reachable, migrations current).
6. **Small modules, explicit dependencies.** `app.ts` builds the server from injected dependencies (db, clock, gateways, config), so tests run the whole stack in-process with a fixed clock and no network.

## Decisions

| Decision | Choice | Why | Revisit if |
|---|---|---|---|
| Web framework | Keep the Figma export: **Vite + React SPA** (not Next.js) | The export is already a complete SPA; an authenticated portal gains little from SSR; a separate API serves both web and Flutter, so Next route handlers would only serve one client | You want SEO pages or server components |
| API server | **Hono** on Node, TypeScript with Node's native type stripping (no build step), `tsc --noEmit` in CI | Small, standards-based (Request/Response), trivially testable via `app.request()` | Team prefers Fastify/Nest |
| Database access | Raw SQL through a 2-method `Db` interface; **PGlite** for dev/test, **node-postgres** for production (`DATABASE_URL`) | SQL is the contract with RLS; an ORM would hide the `SET ROLE` + RLS semantics this design depends on | The query count grows enough to want a query builder (Kysely fits) |
| Auth | **Own accounts** (scrypt password hashes, rotating refresh tokens, 15-minute JWT access tokens, SMS OTP for guardians); an account can hold several people (admin who is also a parent) | No external account needed to run; a person row per school role keeps RLS simple | You adopt Supabase Auth / an IdP: replace `auth/` and `app.person_id()` only |
| Money | `numeric(12,2)` in the database, decimal **strings** on the wire | No float error, ever | - |
| IDs | UUIDs | Safe to generate offline on devices | - |
| Offline | Attendance register and gradebook writes are idempotent batch upserts, **last-write-wins on device `marked_at`**, with per-entry results | One rejected row must never lose a whole queued register | You need field-level merge |
| Web state | `openapi-fetch` + TanStack Query | Typed calls, caching, retries, loading/error states for free (the Figma screens already model those states) | - |
| Mobile | Flutter, Riverpod, go_router, Dio; API client generated from the contract; drift for the offline queue | User's stack; testable, conventional | - |
| Hash routing on web | Kept from the export | Works with any static host, no rewrite rules | You move to real paths (one-file change in `ui.tsx`) |

## Known scaling path (not needed at launch)
- Read replicas for report endpoints (`/schools/:id/attendance_report`); they are read-only and cache-friendly.
- The outbox worker scales horizontally (`for update skip locked`).
- Partition `attendance_records` and `audit_log` by term/month once they pass tens of millions of rows; indexes already lead with the filter columns.
- Move idempotency keys to Redis if write volume makes the table hot.
