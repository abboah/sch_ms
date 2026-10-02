import { createApp } from './app.ts';
import { createDeps } from './bootstrap.ts';
import { loadConfig } from './config.ts';

const config = loadConfig();
const deps = await createDeps(config);
const app = createApp(deps);

export const fetch = app.fetch;
