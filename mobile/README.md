# Homeroom mobile (Flutter)

One app for **teachers** and **parents**; the portal is chosen by the role of whoever signs in. Administrators and
students get a "use the web app" screen.

## Run

Start the API first (see `../backend/README.md`):

```
cd ../backend
SEED_DEMO=true DEMO_NOW=2026-10-05T08:00:00Z PORT=3000 node src/server.ts
```

Then:

```
flutter pub get
flutter run -d edge                       # or an emulator / device
flutter run --dart-define=API_URL=https://api.example.com/v1
```

The default API URL is `http://localhost:3000/v1` (`http://10.0.2.2:3000/v1` on the Android emulator).
Demo logins: `kwame.boateng@greenfield.edu.gh` (teacher), `nana.adjei@greenfield.edu.gh` (parent), password `password123`.

## Check

```
flutter analyze
flutter test
```

## Layout

| Path | What |
|---|---|
| `lib/core/` | session + token refresh, authed HTTP client, offline outbox, failures, theme, formatting, Riverpod wiring |
| `lib/widgets/` | shared building blocks (cards, lists, screen scaffold with loading/empty/error states) |
| `lib/features/` | `auth`, `common`, `parent`, `teacher`, `messages`; one file per screen group, providers beside them |
| `lib/app/` | router (role-guarded go_router), app widget, theme mode |
| `packages/homeroom_api/` | **generated** API client. Never edit by hand |
| `tool/gen_api.sh` | regenerates the client from `../backend/openapi.yaml` |

## Decisions worth knowing

- **Contract first.** The Dart client is generated from the same OpenAPI file the backend tests validate against.
  After changing the API: update `openapi.yaml`, run `tool/gen_api.sh`, then `flutter analyze`.
- **Offline writes.** The attendance register and scores go through `Outbox`: try now; on network failure or 5xx keep the
  write on the device and retry every 15 s and on resume. Each write has an idempotency key, so a retry can never
  apply twice. A 4xx means the server refused, so the write is dropped and reported rather than blocking the queue.
- **Sessions.** The access token is refreshed 30 s before expiry, one refresh at a time. Being offline never signs
  anyone out; only the server rejecting the refresh token does.
- **"Today"** comes from the server clock (`Me.now` offset), not the device, so a wrong phone clock cannot mark the wrong day.

## Not done yet

Report-card comments (placeholder screen — the backend endpoint and web UI exist, `backend/README.md`), widget tests for screens.

**Android**: `flutter build apk --debug` builds cleanly (`build/app/outputs/flutter-apk/app-debug.apk`) — the Gradle/Android SDK pipeline works end to end. Not yet run on a physical device or emulator in this environment (`flutter devices`/`adb devices` found none connected when last tried); install the APK on a device to confirm the actual UI, not just that it compiles.

**iOS**: cannot be built at all from this Windows environment — Xcode only runs on macOS. Needs a Mac (or a cloud Mac CI runner) to attempt.
