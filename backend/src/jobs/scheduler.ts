import type { Deps } from '../context.ts';
import { enqueueFeesDueSoon, processOutbox } from './outbox.ts';

export interface Jobs {
  stop(): Promise<void>;
}

/**
 * In-process scheduler: drains the notification outbox every few seconds and queues fee
 * reminders hourly. Overlap-safe (a run is skipped if the last one is still going). With several
 * API instances every one runs these loops harmlessly: the outbox claim uses `skip locked`, and
 * the reminder insert is idempotent. To move them out of the API, run `src/jobs/worker.ts` instead.
 */
export function startJobs(deps: Deps, opts: { outboxEveryMs?: number; remindersEveryMs?: number } = {}): Jobs {
  let running = false;
  let reminding = false;
  let inFlight: Promise<unknown> = Promise.resolve();

  const tick = () => {
    if (running) return;
    running = true;
    inFlight = processOutbox(deps)
      .catch((err) => deps.log.error('outbox tick failed', { err }))
      .finally(() => { running = false; });
  };
  const remind = () => {
    if (reminding) return;
    reminding = true;
    enqueueFeesDueSoon(deps)
      .then((n) => n && deps.log.info('fee reminders queued', { count: n }))
      .catch((err) => deps.log.error('fee reminder job failed', { err }))
      .finally(() => { reminding = false; });
  };

  const a = setInterval(tick, opts.outboxEveryMs ?? 5_000);
  const b = setInterval(remind, opts.remindersEveryMs ?? 60 * 60 * 1000);
  a.unref();
  b.unref();
  remind();

  return {
    async stop() {
      clearInterval(a);
      clearInterval(b);
      await inFlight;
    },
  };
}
