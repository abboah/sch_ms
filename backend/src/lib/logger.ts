/** Structured JSON logging: one object per line, easy to grep locally and to ship anywhere. */

const LEVELS = { debug: 10, info: 20, warn: 30, error: 40 } as const;
export type Level = keyof typeof LEVELS;

export interface Logger {
  debug(msg: string, fields?: Record<string, unknown>): void;
  info(msg: string, fields?: Record<string, unknown>): void;
  warn(msg: string, fields?: Record<string, unknown>): void;
  error(msg: string, fields?: Record<string, unknown>): void;
  /** A logger that stamps every line with extra fields (e.g. the request id). */
  child(bindings: Record<string, unknown>): Logger;
}

export type Sink = (line: string) => void;

export function createLogger(opts: { level?: Level; sink?: Sink; bindings?: Record<string, unknown> } = {}): Logger {
  const min = LEVELS[opts.level ?? 'info'];
  const sink: Sink = opts.sink ?? ((line) => process.stdout.write(line + '\n'));
  const bindings = opts.bindings ?? {};

  const emit = (level: Level, msg: string, fields?: Record<string, unknown>) => {
    if (LEVELS[level] < min) return;
    sink(JSON.stringify({ t: new Date().toISOString(), level, msg, ...bindings, ...fields }, errorReplacer));
  };

  return {
    debug: (m, f) => emit('debug', m, f),
    info: (m, f) => emit('info', m, f),
    warn: (m, f) => emit('warn', m, f),
    error: (m, f) => emit('error', m, f),
    child: (b) => createLogger({ level: opts.level ?? 'info', sink, bindings: { ...bindings, ...b } }),
  };
}

/** Errors do not serialise by default; keep the useful parts. */
function errorReplacer(_key: string, value: unknown) {
  if (value instanceof Error) {
    const e = value as Error & { code?: string };
    return { name: e.name, message: e.message, code: e.code, stack: e.stack };
  }
  return value;
}

export const silentLogger: Logger = createLogger({ level: 'error', sink: () => undefined });
