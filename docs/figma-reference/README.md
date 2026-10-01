# Figma Make export (reference only)

The original React mock of the **mobile** app from Figma Make (`mobile.tsx`), with the shared UI primitives
(`ui.tsx`) and the mock data (`data.ts`) it was built on. This is not compiled or run. It is the design
reference the Flutter app is built from: every screen, its states, its copy and its layout.

Known differences from the real product, corrected in the Flutter app:
- `data.ts` states Kofi's running average as 76.0% and Yaa's as 88.9%. The correct weighted figures are
  74.5% and 89.1% (the API computes them).
- Dates in the mock used 2025 weekdays; the real demo data uses the 2026 calendar.

The web app in `web/` started from the same export, then was wired to the API (its `Screen`, shell and
data layer were replaced). This folder keeps the untouched originals.
