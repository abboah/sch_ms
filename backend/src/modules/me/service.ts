import type { Tx } from '../../context.ts';
import { notFound } from '../../http/errors.ts';
import type { Schemas } from '../../http/helpers.ts';

/**
 * "Who am I and what can I switch between." Runs as the caller, so it only ever returns
 * what row-level security lets that person see.
 */
export async function loadMe(tx: Tx, personId: string, now: Date): Promise<Schemas['Me']> {
  const p = await tx.query<{
    id: string;
    full_name: string;
    role: Schemas['Role'];
    school_id: string;
    school_name: string;
    timezone: string;
  }>(
    `select p.id, p.full_name, p.role, s.id as school_id, s.name as school_name, s.timezone
       from people p join schools s on s.id = p.school_id where p.id = $1`,
    [personId],
  );
  const row = p.rows[0];
  if (!row) throw notFound('Person');

  const me: Schemas['Me'] = {
    id: row.id,
    full_name: row.full_name,
    role: row.role,
    school: { id: row.school_id, name: row.school_name, timezone: row.timezone },
    now: now.toISOString(),
  };

  // The term containing today (in the school's timezone), for the header.
  const today = new Intl.DateTimeFormat('en-CA', { timeZone: row.timezone, year: 'numeric', month: '2-digit', day: '2-digit' }).format(now);
  const term = await tx.query<Schemas['Term']>(
    'select id, name, starts_on, ends_on, closed from terms where $1::date between starts_on and ends_on order by starts_on desc limit 1',
    [today],
  );
  if (term.rows[0]) me.school.term = term.rows[0];

  const contact = await tx.query<{ phone: string | null; email: string | null }>(
    'select phone, email from person_contacts where person_id = $1',
    [personId],
  );
  me.contact = contact.rows[0] ?? { phone: null, email: null };

  if (row.role === 'guardian') {
    // One chip per child; if a child has several active sections, prefer the lowest-named one.
    const kids = await tx.query<{ id: string; full_name: string; section_id: string | null; section_name: string | null }>(
      `select distinct on (st.id) st.id, st.full_name, cs.id as section_id, cs.name as section_name
         from guardian_student gs
         join people st on st.id = gs.student_id
         left join enrollments e on e.student_id = st.id and e.status = 'active'
         left join class_sections cs on cs.id = e.class_section_id
        where gs.guardian_id = $1
        order by st.id, cs.name`,
      [personId],
    );
    me.children = kids.rows
      .map((k) => ({
        id: k.id,
        full_name: k.full_name,
        ...(k.section_id && k.section_name ? { class_section: { id: k.section_id, name: k.section_name } } : {}),
      }))
      .sort((a, b) => a.full_name.localeCompare(b.full_name));
  }

  if (row.role === 'teacher') {
    const secs = await tx.query<{ id: string; name: string; grade_level: string; term_id: string; subject: string }>(
      `select cs.id, cs.name, cs.grade_level, cs.term_id, string_agg(st.subject, ', ' order by st.subject) as subject
         from section_teachers st
         join class_sections cs on cs.id = st.section_id
         join terms t on t.id = cs.term_id and not t.closed
        where st.teacher_id = $1
        group by cs.id order by cs.name`,
      [personId],
    );
    me.sections = secs.rows;
  }
  return me;
}
