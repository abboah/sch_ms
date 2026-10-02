# Homeroom backend: schema, RLS, seed, tests

Postgres is the permission engine. Every rule in the spec's "Who can see what" table is a row-level security policy, and the tests prove it. Runs locally on PGlite (embedded Postgres, no install or accounts).

```
npm install
npm test        # 27 tests, about 12 s
```

## Layout
| Path | What |
|---|---|
| `migrations/001_schema.sql` | 22 tables, enums, composite `(id, school_id)` foreign keys so rows cannot reference another school |
| `migrations/002_functions.sql` | RLS helper functions, `student_summary`, `book_conference_slot`, `apply_payment_webhook`, read auditing |
| `migrations/003_rls.sql` | Policies and grants |
| `seed/seed.sql` | Greenfield Academy (matches `docs/03-mock-data.md`) plus Riverside Prep for tenant tests |
| `openapi.yaml` | The API contract for web and Flutter: 64 operations, lints clean, generates a Dart client |
| `src/db.mjs` | `createDb()` and `as(db, 'p:akua', fn)`, which runs `fn` as that person under the non-superuser `app_user` role |

## How identity works
The API sets `app.person_id` for each request (transaction-local) and runs as `app_user`. On Supabase, replace `app.person_id()` with a lookup from `auth.uid()` via `people.auth_user_id`, and map `app_user` to `authenticated`. Service-role work (webhooks, seeding) runs as the owner and bypasses RLS.

## Decisions worth knowing
- **No hard deletes** on people, enrollments, attendance, invoices or payments: there is no DELETE policy. Withdrawal is `enrollments.status`.
- **Closed terms lock teachers** (attendance, grades, assessments, homework). Admin can still correct attendance. Nobody in-app can edit grades after close; change that rule in `003_rls.sql` if admins should be able to.
- **Invoices change state only in `apply_payment_webhook`**, idempotent on `provider_ref`. A stale or replayed event cannot downgrade a settled payment. It is not executable by `app_user`.
- **Read auditing** is done in `student_summary()` via `app.log_read()`, not by RLS (RLS cannot log SELECTs). Any endpoint that returns a student's record should go through a function that calls it. Direct table reads by a parent or teacher are not logged.
- **Attendance rate** = (present + late) / all marked; excused counts as absent for the rate and is reported separately. **Running grade** = weighted over assessments that have a score.
- **Guardians book conferences through `book_conference_slot()`**, not UPDATE, so they cannot alter a slot's teacher or time (RLS cannot restrict columns).

## Known gaps (not yet handled)
1. **Real integrations are written but not exercised against a live account.** Paystack (`src/integrations/paystack.ts`), Twilio and Hubtel SMS (`src/integrations/sms.ts`), FCM v1 push (`src/integrations/push.ts`) all implement the same ports the sandbox/console versions do, and `test/integrations.test.ts` covers their request shaping and response parsing against a mocked `fetch` — built from each provider's published API docs, not run against a real account. Before relying on any of them in production: run one real transaction/message/push with that provider's test credentials and confirm the payload shapes in the adapter still match (gateways change field names between API versions). Selected via `PAYMENT_GATEWAY`/`SMS_PROVIDER`/`PUSH_PROVIDER`; opting into a real provider without its credentials fails at boot, in any environment — see `.env.example`. **Deliberately deferred to v2**: for an MVP/evaluation deploy, set `ALLOW_SANDBOX_PAYMENTS=true` to run `NODE_ENV=production` (real secrets, real DB, locked CORS) with `PAYMENT_GATEWAY=sandbox` and `SMS_PROVIDER`/`PUSH_PROVIDER` left at their `console` default — no real money moves, no real SMS/push sends, everything else about the deploy is production-shaped.
2. Analytics has no endpoint — explicitly deferred to Term 3 by the original design doc, not attempted.
3. **School onboarding is CLI-only.** `POST /schools` exists (see below) but invite codes are minted with `node src/cli.ts create-invite`, not through the API — there is no `platform_admin` role yet, by design, until self-serve signup is worth the abuse-control work it needs.
4. Tests run in one shared database in file order, and mutating tests clean up after themselves. If you add tests, keep that convention or give a test its own `createDb()`.

**School-configurable, as of `migrations/008`:** a school's grading scale (`grade_bands`, admin-write/school-read, surfaced as `grade_band` alongside every `running_grade`) and reusable named fees (`fee_items`, admin-only, `invoices.fee_item_id` is a convenience/reporting tag — `description`/`amount_due` on an invoice are still explicit either way). Both are purely additive: a school that configures neither sees exactly what it saw before migration 008.

**Report-card comments, as of `migrations/009`:** one comment per (student, class section, subject) written by the teacher while the term is open (`PATCH /class_sections/{id}/comments`), visible to the guardian only once the term closes — `terms.closed` doubles as "issued," no new state invented. Admin can always view.

**Bulk student import, as of this pass:** `POST /class_sections/{id}/students/import` creates and enrols a batch of new students from a list of names. Deliberately name-only (no matching against existing people, no guardian linking in the same call) — that's a product decision to keep the import format honest about what it actually does, not a stopgap.

*(Column exposure — a parent reading their child's teacher's full `contact` — was closed in `migrations/004_platform.sql`: `contact` moved to its own `person_contacts` table with self/admin-only RLS.)*

## Running
```
npm install
SEED_DEMO=true DEMO_NOW=2026-10-05T08:00:00Z PORT=3000 node src/server.ts   # embedded PGlite in .data/pglite
DATABASE_URL=postgres://... node src/server.ts                               # real Postgres
npm test             # 230 tests: RLS, tenant isolation, OpenAPI conformance, adapter request/response shaping
npx tsc --noEmit
```
The server does not hot reload: restart it after changing source, or a stale process will serve old response shapes.
`/healthz` is liveness and `/readyz` checks the database. Errors are `application/problem+json` with stable `code`s and a `request_id`.

**Onboarding a new school:** `node src/cli.ts create-invite [--expires-in-days N]` prints a one-time code (14-day default). Hand it to the school; they redeem it with `POST /schools` (no login) to create the school and its first admin, who gets the same set-password email/SMS `POST /people` sends. Against the embedded PGlite database, run the CLI and the server **sequentially, not concurrently** — PGlite's file-backed store isn't safe for two processes writing to the same directory at once, so a code minted while the server is running may not be visible to it. This is a PGlite-only caveat: with `DATABASE_URL` pointed at real Postgres, the CLI and server are just two ordinary client connections and can run at the same time.

## API contract
`openapi.yaml` is the source of truth. It generates the TypeScript types (`npm run gen:types`), drives the conformance tests,
and generates the web types and the Dart client (`../mobile/tool/gen_api.sh`, needs Java 11+). Change the contract first, then the code.

Things the contract decides that the database alone does not:
- **Offline sync:** `PUT /class_sections/{id}/attendance` takes `marked_at` per entry, is last-write-wins on it, and returns a per-entry outcome (`applied` / `stale` / `rejected`) so one bad row never loses a queued register. `Idempotency-Key` on writes.
- **Payments:** `POST /invoices/{id}/pay` only starts a payment (202). Only the webhook settles the invoice; clients poll `GET /payments/{id}`.
- **404 vs 403:** rows the caller cannot see are 404 so existence is not leaked.
- **Not in the contract yet** (needs schema first): unread counts on threads (the field exists; the storage does not).
