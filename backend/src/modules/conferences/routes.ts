import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps, Tx } from '../../context.ts';
import { forbidden, notFound, unprocessable } from '../../http/errors.ts';
import { asCaller, body, idParam, isoDate, query, uuid, type Schemas } from '../../http/helpers.ts';
import { requireRole } from '../../http/middleware.ts';
import { personRef, studentRef } from '../shared.ts';

const MAX_SLOTS_PER_REQUEST = 100;

interface SlotRow {
  id: string; teacher_id: string; teacher_name: string; starts_at: Date; ends_at: Date;
  booked_by_guardian_id: string | null; student_id: string | null; student_name: string | null;
}

const SLOT_SELECT = `
  select s.id, s.teacher_id, t.full_name as teacher_name, s.starts_at, s.ends_at, s.booked_by_guardian_id,
         s.student_id, st.full_name as student_name
    from conference_slots s join people t on t.id = s.teacher_id left join people st on st.id = s.student_id`;

const toSlot = (s: SlotRow, meId: string): Schemas['ConferenceSlot'] => ({
  id: s.id,
  teacher: personRef({ id: s.teacher_id, full_name: s.teacher_name, role: 'teacher' }),
  starts_at: s.starts_at.toISOString(),
  ends_at: s.ends_at.toISOString(),
  booked: s.booked_by_guardian_id != null,
  booked_by_me: s.booked_by_guardian_id === meId,
  ...(s.student_id && s.student_name ? { student: studentRef({ id: s.student_id, full_name: s.student_name }) } : {}),
});

async function slotById(tx: Tx, id: string, meId: string): Promise<Schemas['ConferenceSlot']> {
  const r = await tx.query<SlotRow>(`${SLOT_SELECT} where s.id = $1`, [id]);
  if (!r.rows[0]) throw notFound('Conference slot');
  return toSlot(r.rows[0], meId);
}

export function conferenceRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();

  r.get('/conference_slots', async (c) => {
    const q = query(c, z.object({ teacher_id: uuid.optional(), from: isoDate.optional() }));
    return c.json({
      items: await asCaller(deps, c, async (tx, me) => {
        const rows = await tx.query<SlotRow>(
          `${SLOT_SELECT}
            where ($1::uuid is null or s.teacher_id = $1) and ($2::date is null or s.starts_at >= $2::date)
            order by s.starts_at, s.id`,
          [q.teacher_id ?? null, q.from ?? null],
        );
        return rows.rows.map((s) => toSlot(s, me.personId));
      }),
    });
  });

  /** A window (say 09:00 to 12:00) cut into equal slots. Existing slots at the same time are left alone. */
  r.post('/conference_slots', requireRole('teacher', 'admin'), async (c) => {
    const b = await body(
      c,
      z.object({ teacher_id: uuid, starts_at: z.iso.datetime(), ends_at: z.iso.datetime(), slot_minutes: z.number().int().min(5).max(120) }),
    );
    const start = new Date(b.starts_at).getTime();
    const end = new Date(b.ends_at).getTime();
    const step = b.slot_minutes * 60_000;
    if (end <= start) throw unprocessable('The window must end after it starts', 'invalid_window');
    if ((end - start) / step > MAX_SLOTS_PER_REQUEST) {
      throw unprocessable(`That would create more than ${MAX_SLOTS_PER_REQUEST} slots; use a shorter window`, 'too_many_slots');
    }
    return c.json(
      { items: await asCaller(deps, c, async (tx, me) => {
        try {
          const ins = await tx.attempt(() =>
            tx.query<{ id: string }>(
              `insert into conference_slots (school_id, teacher_id, starts_at, ends_at)
               select app.school_id(), $1, t, t + ($4::int * interval '1 minute')
                 from generate_series($2::timestamptz, $3::timestamptz - ($4::int * interval '1 minute'), ($4::int * interval '1 minute')) t
               on conflict (teacher_id, starts_at) do nothing returning id`,
              [b.teacher_id, b.starts_at, b.ends_at, b.slot_minutes],
            ),
          );
          const rows = await tx.query<SlotRow>(`${SLOT_SELECT} where s.id = any($1::uuid[]) order by s.starts_at`, [ins.rows.map((x) => x.id)]);
          return rows.rows.map((s) => toSlot(s, me.personId));
        } catch (err) {
          if ((err as { code?: string }).code === '42501') throw forbidden('Teachers can only create slots for themselves', 'not_your_slots');
          throw err;
        }
      }) },
      201,
    );
  });

  r.put('/conference_slots/:id/booking', requireRole('guardian'), async (c) => {
    const id = idParam(c);
    const b = await body(c, z.object({ student_id: uuid }));
    return c.json(
      await asCaller(deps, c, async (tx, me) => {
        try {
          await tx.attempt(() => tx.query('select book_conference_slot($1, $2)', [id, b.student_id]));
        } catch (err) {
          if ((err as { code?: string }).code === '42501') throw notFound('Conference slot');
          throw err;
        }
        return slotById(tx, id, me.personId);
      }),
    );
  });

  r.delete('/conference_slots/:id/booking', requireRole('guardian'), async (c) => {
    const id = idParam(c);
    await asCaller(deps, c, (tx) => tx.query('select release_conference_slot($1)', [id]));
    return c.body(null, 204);
  });

  return r;
}
