import { Hono } from 'hono';
import { z } from 'zod';
import type { AppEnv, Deps } from '../../context.ts';
import { createAuthService } from '../../auth/service.ts';
import { normalizePhone } from '../../auth/phone.ts';
import { badRequest, notFound } from '../../http/errors.ts';
import { asCaller, body, decodeCursor, idParam, isoDate, pageQuery, paginate, query, uuid, type Schemas } from '../../http/helpers.ts';
import { requireRole } from '../../http/middleware.ts';

interface PersonRow { id: string; full_name: string; role: Schemas['Role']; phone: string | null; email: string | null }

const toPerson = (p: PersonRow): Schemas['Person'] => ({
  id: p.id,
  full_name: p.full_name,
  role: p.role,
  ...(p.phone || p.email ? { contact: { ...(p.phone ? { phone: p.phone } : {}), ...(p.email ? { email: p.email } : {}) } } : {}),
});

const PERSON_SELECT = `select p.id, p.full_name, p.role, c.phone, c.email from people p left join person_contacts c on c.person_id = p.id`;

/** Audit ids are sequential integers, so their cursor is just the last id seen. */
const encodeAuditCursor = (id: number): string => Buffer.from(String(id)).toString('base64url');
function decodeAuditCursor(token: string | undefined): number | undefined {
  if (!token) return undefined;
  const n = Number(Buffer.from(token, 'base64url').toString('utf8'));
  if (!Number.isInteger(n) || n <= 0) throw badRequest('Invalid cursor', 'invalid_cursor');
  return n;
}

export function adminRoutes(deps: Deps): Hono<AppEnv> {
  const r = new Hono<AppEnv>();
  const admin = requireRole('admin');
  const auth = createAuthService(deps);

  r.get('/people', admin, async (c) => {
    const q = query(c, pageQuery.extend({ role: z.enum(['admin', 'teacher', 'guardian']).optional(), q: z.string().max(100).optional() }));
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps, c, async (tx): Promise<Schemas['PersonPage']> => {
        const params: unknown[] = [q.limit + 1, q.role ?? null, q.q ?? null];
        let cursorSql = '';
        if (cur) {
          params.push(cur.t, cur.id);
          cursorSql = `and (p.full_name, p.id) > ($4, $5::uuid)`;
        }
        const rows = await tx.query<PersonRow>(
          `${PERSON_SELECT}
            where p.role <> 'student' and ($2::person_role is null or p.role = $2::person_role)
              and ($3::text is null or strpos(lower(p.full_name), lower($3)) > 0) ${cursorSql}
            order by p.full_name, p.id limit $1`,
          params,
        );
        const page = paginate(rows.rows, q.limit, (p) => p.full_name);
        const teacherIds = page.items.filter((p) => p.role === 'teacher').map((p) => p.id);
        const assignments = new Map<string, NonNullable<Schemas['Person']['assignments']>>();
        if (teacherIds.length) {
          const a = await tx.query<{ teacher_id: string; section_id: string; section_name: string; subject: string }>(
            `select st.teacher_id, cs.id as section_id, cs.name as section_name, st.subject
               from section_teachers st join class_sections cs on cs.id = st.section_id
               join terms t on t.id = cs.term_id and not t.closed
              where st.teacher_id = any($1::uuid[]) order by cs.name, st.subject`,
            [teacherIds],
          );
          for (const x of a.rows) {
            const list = assignments.get(x.teacher_id) ?? [];
            list.push({ class_section: { id: x.section_id, name: x.section_name }, subject: x.subject });
            assignments.set(x.teacher_id, list);
          }
        }
        return {
          items: page.items.map((p) => ({ ...toPerson(p), ...(assignments.has(p.id) ? { assignments: assignments.get(p.id)! } : {}) })),
          next_cursor: page.next_cursor,
        };
      }),
    );
  });

  r.post('/people', admin, async (c) => {
    const b = await body(
      c,
      z.object({
        full_name: z.string().trim().min(1).max(120),
        role: z.enum(['admin', 'teacher', 'guardian', 'student']),
        email: z.email().optional(),
        phone: z.string().min(6).max(25).optional(),
        invite: z.boolean().default(false),
      }),
    );
    const phone = b.phone ? normalizePhone(b.phone, deps.config.DEFAULT_COUNTRY_CODE) : null;
    const email = b.email ? b.email.toLowerCase() : null;
    const person = await asCaller(deps, c, async (tx, me) => {
      const p = await tx.query<{ id: string }>(
        'insert into people (school_id, full_name, role) values ($1, $2, $3) returning id',
        [me.schoolId, b.full_name, b.role],
      );
      const id = p.rows[0]!.id;
      if (phone || email) {
        await tx.query('insert into person_contacts (person_id, school_id, phone, email) values ($1, $2, $3, $4)', [id, me.schoolId, phone, email]);
      }
      return toPerson({ id, full_name: b.full_name, role: b.role, phone, email });
    });
    if (b.invite && b.role !== 'student') await auth.inviteAccount(person.id, { email, phone });
    return c.json(person, 201);
  });

  r.put('/students/:id/guardians', admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, z.object({ guardian_id: uuid, relationship: z.string().max(40).optional(), is_primary_contact: z.boolean().optional() }));
    await asCaller(deps, c, async (tx, me) => {
      const s = await tx.query(`select 1 from people where id = $1 and role = 'student'`, [id]);
      if (s.rowCount === 0) throw notFound('Student');
      await tx.query(
        `insert into guardian_student (school_id, guardian_id, student_id, relationship, is_primary_contact)
         values ($1, $2, $3, coalesce($4, 'guardian'), coalesce($5, false))
         on conflict (guardian_id, student_id) do update
           set relationship = coalesce($4, guardian_student.relationship),
               is_primary_contact = coalesce($5, guardian_student.is_primary_contact)`,
        [me.schoolId, b.guardian_id, id, b.relationship ?? null, b.is_primary_contact ?? null],
      );
    });
    return c.body(null, 204);
  });

  r.get('/audit_log', admin, async (c) => {
    const q = query(c, pageQuery.extend({ student_id: uuid.optional(), actor_id: uuid.optional(), from: isoDate.optional() }));
    const cur = decodeAuditCursor(q.cursor);
    return c.json(
      await asCaller(deps, c, async (tx) => {
        const rows = await tx.query<{
          id: string; action: string; table_name: string; student_id: string | null; student_name: string | null; at: Date;
          actor_id: string; actor_name: string; actor_role: Schemas['Role'];
        }>(
          `select l.id, l.action, l.table_name, l.student_id, s.full_name as student_name, l.at,
                  a.id as actor_id, a.full_name as actor_name, a.role as actor_role
             from audit_log l join people a on a.id = l.actor_id left join people s on s.id = l.student_id
            where ($1::uuid is null or l.student_id = $1) and ($2::uuid is null or l.actor_id = $2)
              and ($3::date is null or l.at >= $3::date) and ($4::bigint is null or l.id < $4)
            order by l.id desc limit $5`,
          [q.student_id ?? null, q.actor_id ?? null, q.from ?? null, cur ?? null, q.limit + 1],
        );
        const items = rows.rows.slice(0, q.limit);
        const last = items[items.length - 1];
        return {
          items: items.map((l): Schemas['AuditEntry'] => ({
            id: Number(l.id),
            actor: { id: l.actor_id, full_name: l.actor_name, role: l.actor_role },
            action: l.action,
            table_name: l.table_name,
            student_id: l.student_id,
            ...(l.student_id && l.student_name ? { student: { id: l.student_id, full_name: l.student_name } } : {}),
            at: l.at.toISOString(),
          })),
          next_cursor: rows.rows.length > q.limit && last ? encodeAuditCursor(Number(last.id)) : null,
        };
      }),
    );
  });

  return r;
}
