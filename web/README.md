# Homeroom web

Admin, teacher and parent portals. Vite 8, React 19, Tailwind 4, TanStack Query, hash router. It began as the Figma Make
export and was kept as Vite rather than moved to Next.js; nothing here needs server rendering.

## Run

API on :3000 (see `../backend/README.md`), then:

```
npx pnpm@10 install      # or npm install
npx vite                 # http://localhost:5173, /v1 is proxied to :3000
```

Demo logins (password `password123`): `esi.mensah@greenfield.edu.gh` (admin), `kwame.boateng@greenfield.edu.gh` (teacher),
`nana.adjei@greenfield.edu.gh` (parent). Guardians can also sign in by SMS code (`024 000 0001`).

## Check

```
npx tsc --noEmit
npx vitest run
npx vite build
```

## Layout

- `src/api/`: session + refresh, typed `openapi-fetch` client (types generated from `../backend/openapi.yaml`), error mapping
- `src/offline/queue.ts`: offline write queue (localStorage), idempotency keys, retry every 15 s and on `online`
- `src/admin/`, `src/teacher/`, `src/parent/`: one folder per portal
- `src/pages/`: sign-in and screens shared between portals
- `src/ui.tsx`: design-system components with real loading, empty and error states

## Not done yet

Report-card comments and analytics are "coming soon" placeholders; bulk import.
