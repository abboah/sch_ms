/** Injected everywhere time matters, so tests can fix it and behaviour never depends on the wall clock. */
export interface Clock {
  now(): Date;
}

export const systemClock: Clock = { now: () => new Date() };

export function fixedClock(iso: string): Clock & { set(iso: string): void; advance(ms: number): void } {
  let t = new Date(iso).getTime();
  return {
    now: () => new Date(t),
    set: (next) => {
      t = new Date(next).getTime();
    },
    advance: (ms) => {
      t += ms;
    },
  };
}
