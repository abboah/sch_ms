import { defineConfig } from "vitest/config";

// Separate from vite.config.ts on purpose: that file carries the Figma Make dev plugins, which tests do not need.
export default defineConfig({
  test: {
    environment: "jsdom",
    include: ["src/**/*.test.ts", "src/**/*.test.tsx"],
    restoreMocks: true,
  },
});
