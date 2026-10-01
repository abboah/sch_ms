import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps } from '../../context.ts';
import { notFound, unprocessable } from '../../http/errors.ts';
import { asCaller, body, idParam, type Schemas } from '../../http/helpers.ts';
import { requireRole } from '../../http/middleware.ts';

/**
 * A school's own grading scale (e.g. A 80-100). Read by anyone in the school; written by admin
 * only. A school that never configures one keeps seeing the bare numeric running grade it always has.
 */
const bandBase = z.object({
  label: z.string().min(1).max(40),
  min_score: z.number().min(0).max(100000),
  max_score: z.number().min(0).max(100000),
});

interface BandRow { id: string; label: string; min_score: string; max_score: string }
const toBand = (b: BandRow): Schemas['GradeBand'] => ({ id: b.id, label: b.label, min_score: Number(b.min_score), max_score: Number(b.max_score) });

export function gradingRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();
  const admin = requireRole('admin');

  r.get('/grade_bands', async (c) =>
    c.json({
      items: await asCaller(deps, c, async (tx) => {
        const rows = await tx.query<BandRow>('select id, label, min_score, max_score from grade_bands order by min_score desc');
        return rows.rows.map(toBand);
      }),
    }),
  );

  r.post('/grade_bands', admin, async (c) => {
    const b = await body(c, bandBase);
    if (b.min_score > b.max_score) throw unprocessable('min_score must not exceed max_score', 'invalid_range');
    const out = await asCaller(deps, c, async (tx, me) => {
      const row = await tx.query<BandRow>(
        `insert into grade_bands (school_id, label, min_score, max_score) values ($1, $2, $3, $4)
         returning id, label, min_score, max_score`,
        [me.schoolId, b.label, b.min_score, b.max_score],
      );
      return toBand(row.rows[0]!);
    });
    return c.json(out, 201);
  });

  r.patch('/grade_bands/:id', admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, bandBase.partial());
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const cur = await tx.query<BandRow>('select id, label, min_score, max_score from grade_bands where id = $1', [id]);
        const existing = cur.rows[0];
        if (!existing) throw notFound('Grade band');
        const min = b.min_score ?? Number(existing.min_score);
        const max = b.max_score ?? Number(existing.max_score);
        if (min > max) throw unprocessable('min_score must not exceed max_score', 'invalid_range');
        const row = await tx.query<BandRow>(
          `update grade_bands set label = $2, min_score = $3, max_score = $4 where id = $1
           returning id, label, min_score, max_score`,
          [id, b.label ?? existing.label, min, max],
        );
        return toBand(row.rows[0]!);
      }),
    );
  });

  r.delete('/grade_bands/:id', admin, async (c) => {
    const id = idParam(c);
    await asCaller(deps, c, async (tx) => {
      const del = await tx.query('delete from grade_bands where id = $1', [id]);
      if (del.rowCount === 0) throw notFound('Grade band');
    });
    return c.body(null, 204);
  });

  return r;
}
