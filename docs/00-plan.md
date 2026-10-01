# Homeroom: build plan

Source spec: https://claude.ai/artifact/4ZBBhSW5ME2nbAKP79C9qg

## Workflow
1. **Package** (this folder): design system, screen inventory, mock data, two Figma Make prompts.
2. **Figma Make, web**: paste `04-figma-make-web.md`, iterate, export the Next.js code into `sch_ms/web`.
3. **Claude, web**: wire the exported UI to the real backend (Postgres/RLS, auth, API routes from the spec).
4. **Figma Make, mobile**: paste `05-figma-make-mobile.md`. Keep as a separate Figma file.
5. **Claude + Figma MCP, mobile**: build the Flutter app (`sch_ms/mobile`) from the Figma file: `ThemeData` from the Figma variables, one widget per Figma component, one screen per frame. Suggested stack: Riverpod, go_router, supabase_flutter (or Dio against our API), drift for offline attendance/gradebook queue, firebase_messaging for push. The Figma MCP is not connected in this session, so it must be added before step 5.

## Assumptions I made (change any you disagree with)
| Decision | Default | Why |
|---|---|---|
| Web covers | Admin (full), Teacher (full), Parent (lighter web view) | Spec's Term 1 promises a parent view but the parent app is Term 2 |
| Mobile covers | Teacher + Parent, one app split by role at login | Spec: one codebase, role split |
| Mobile framework | **Flutter** (decided) | User is a Flutter dev; matches the spec. Figma Make's React output is reference only for mobile, the real build comes from the Figma file via the Figma MCP |
| Currency / locale in mock data | GH¢, Ghana school names, mobile money | Spec mentions Paystack/Hubtel; placeholder only |
| Scope | Term 1 + Term 2 screens (messaging, payments, conferences) designed now | Design the whole UI once; build in rollout order |

## Spec gaps to resolve in the schema (before step 3)
- Add tables: `messages`, `terms`, `announcements`, `homework`, `conference_slots`, `push_tokens`, `notification_prefs`, `audit_log`, `periods` (timetable slots).
- `attendance_records` needs a `period_id`.
- Read-audit logging cannot be done by RLS alone. Decide on API-layer logging.
- Fix the spec's "Section 04" reference (it is section 07).

## Files
- `01-design-system.md`: tokens, type, components
- `02-screen-inventory.md`: every screen, per portal and platform
- `03-mock-data.md`: one consistent fictional school for all screens
- `04-figma-make-web.md`: paste-ready prompt
- `05-figma-make-mobile.md`: paste-ready prompt

## Status
- [x] Design package (this folder)
- [x] Backend: schema, RLS, seed, OpenAPI contract (~75 operations), 194 passing tests (`backend/`)
- [x] Figma Make web and mobile generated (Vite + React export; mobile used as visual reference only)
- [x] Web app wired to the real backend (`web/`: admin, teacher, parent; 29 tests; verified live)
- [x] Flutter app for teachers and parents (`mobile/`: analyzer clean, 22 tests, web build verified live against the API)
- [x] School onboarding: invite-code signup (`POST /schools`, `node backend/src/cli.ts create-invite`) — a new school and its first admin, no `platform_admin` role yet (codes are minted out of band); 199 backend tests passing
- [x] Web onboarding page (`web/`: "New school? Create one" on sign-in → `/#/onboard`, redeems an invite code through `POST /schools`)
- [x] Grade bands + fee items: per-school configurable grading scale (`/grade_bands`, admin tab "Structure → Grading") and reusable named fees (`/fee_items`, admin "Fees" page) — both additive
- [x] Report-card comments (web: teacher "Comments" writes per subject/section while the term is open, parent "Reports" reads once the term closes; mobile placeholder not yet updated) — 214 backend + 31 web tests passing
- [x] Bulk import (`POST /class_sections/{id}/students/import`: paste names, one per line, creates + enrolls each as a new student; admin "Enrollment" page. Deliberately name-only, no CSV columns for guardian/ID matching — kept the format honest about what's actually built) — 217 backend + 31 web tests passing
- [ ] Analytics (explicitly deferred to Term 3 by the original design doc — not attempted this pass)
- [x] Real integration adapters written: Paystack, Twilio/Hubtel SMS, FCM v1 push (`backend/src/integrations/`), selected via `PAYMENT_GATEWAY`/`SMS_PROVIDER`/`PUSH_PROVIDER` — request/response shaping unit-tested against mocked `fetch`, but **not exercised against any live provider account** (no credentials available); confirm against real test credentials before production use — 230 backend tests passing
- [ ] Real adapters: Paystack, FCM push, Hubtel/Twilio SMS (console and sandbox implementations exist)
- [x] Android build pipeline verified: `flutter build apk --debug` succeeds end to end (Gradle/Android SDK), Dart API client regenerated from the current contract, `flutter analyze`/`flutter test` clean (22 tests). **Not run on an actual device or emulator** — none was visible to `flutter devices`/`adb devices` in this environment when tried; sideload the APK on a real device to confirm the UI itself.
- [ ] iOS build — cannot be attempted from Windows at all; needs a Mac (Xcode is macOS-only)
- [ ] Flutter widget tests for screens (logic layer is covered)
