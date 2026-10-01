import type { Tx } from '../context.ts';

/**
 * What each outbox event means to people: who is told, and what the message says.
 * Runs with service privileges (the worker has no signed-in user), so every query here is
 * explicit about school and relationship. Adding a notification = adding one handler.
 */

export interface OutboxEvent {
  id: number;
  school_id: string;
  kind: string;
  ref_id: string | null;
  student_id: string | null;
  payload: Record<string, unknown>;
}

export interface Draft {
  personId: string;
  title: string;
  body: string;
  data: Record<string, string>;
  /** Also email this (receipts). Other kinds are push, with SMS fallback where SMS_KINDS allows. */
  email?: { subject: string; text: string };
}

/** Kinds worth a text message when a parent has no app: things they would want the same hour. */
export const SMS_KINDS = new Set(['attendance.marked', 'payment.succeeded', 'fees.due_soon']);

type Handler = (tx: Tx, e: OutboxEvent) => Promise<Draft[]>;

const cedi = (n: string | number) => `GH¢${Number(n).toLocaleString('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
const clip = (s: string, n: number) => (s.length > n ? `${s.slice(0, n - 1)}…` : s);
const longDate = (iso: string) =>
  new Date(`${iso}T00:00:00Z`).toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short', timeZone: 'UTC' });

async function guardiansOfStudent(tx: Tx, studentId: string): Promise<string[]> {
  const r = await tx.query<{ guardian_id: string }>('select guardian_id from guardian_student where student_id = $1', [studentId]);
  return r.rows.map((x) => x.guardian_id);
}

async function guardiansOfSection(tx: Tx, sectionId: string): Promise<string[]> {
  const r = await tx.query<{ guardian_id: string }>(
    `select distinct gs.guardian_id from enrollments e join guardian_student gs on gs.student_id = e.student_id
      where e.class_section_id = $1 and e.status = 'active'`,
    [sectionId],
  );
  return r.rows.map((x) => x.guardian_id);
}

const handlers: Record<string, Handler> = {
  async 'attendance.marked'(tx, e) {
    if (!e.ref_id || !e.student_id) return [];
    const r = await tx.query<{ full_name: string; status: string; period_date: string; subject: string | null; section: string }>(
      `select st.full_name, a.status, a.period_date, p.subject, cs.name as section
         from attendance_records a join people st on st.id = a.student_id
         join class_sections cs on cs.id = a.class_section_id left join periods p on p.id = a.period_id
        where a.id = $1`,
      [e.ref_id],
    );
    const a = r.rows[0];
    if (!a) return [];
    const what = a.status === 'late' ? 'was marked late' : 'was marked absent';
    const body = `${a.full_name} ${what} on ${longDate(a.period_date)}${a.subject ? ` (${a.subject})` : ''}.`;
    return (await guardiansOfStudent(tx, e.student_id)).map((personId) => ({
      personId, title: a.status === 'late' ? 'Marked late' : 'Marked absent', body,
      data: { kind: e.kind, student_id: e.student_id!, date: a.period_date },
    }));
  },

  async 'homework.posted'(tx, e) {
    const sectionId = String(e.payload['class_section_id'] ?? '');
    if (!sectionId) return [];
    const title = String(e.payload['title'] ?? 'Homework');
    const due = String(e.payload['due_date'] ?? '');
    const s = await tx.query<{ name: string }>('select name from class_sections where id = $1', [sectionId]);
    return (await guardiansOfSection(tx, sectionId)).map((personId) => ({
      personId, title: `New homework: ${clip(title, 60)}`,
      body: `${s.rows[0]?.name ?? 'Class'}${due ? `, due ${longDate(due)}` : ''}.`,
      data: { kind: e.kind, class_section_id: sectionId },
    }));
  },

  async 'announcement.published'(tx, e) {
    const sectionId = (e.payload['class_section_id'] as string | null) ?? null;
    const a = e.ref_id ? await tx.query<{ title: string; body: string }>('select title, body from announcements where id = $1', [e.ref_id]) : null;
    const row = a?.rows[0];
    if (!row) return [];
    const ids = sectionId
      ? await guardiansOfSection(tx, sectionId)
      : (await tx.query<{ id: string }>(`select id from people where school_id = $1 and role = 'guardian'`, [e.school_id])).rows.map((x) => x.id);
    return ids.map((personId) => ({
      personId, title: clip(row.title, 80), body: clip(row.body, 140), data: { kind: e.kind, announcement_id: e.ref_id! },
    }));
  },

  async 'message.sent'(tx, e) {
    const senderId = String(e.payload['sender_id'] ?? '');
    const threadId = String(e.payload['thread_id'] ?? '');
    const m = await tx.query<{ body: string; sender: string; student: string; teacher_id: string; guardian_id: string }>(
      `select m.body, s.full_name as sender, st.full_name as student, t.teacher_id, t.guardian_id
         from messages m join message_threads t on t.id = m.thread_id
         join people s on s.id = m.sender_id join people st on st.id = t.student_id where m.id = $1`,
      [e.ref_id],
    );
    const row = m.rows[0];
    if (!row) return [];
    const to = senderId === row.teacher_id ? row.guardian_id : row.teacher_id;
    return [{
      personId: to, title: `New message about ${row.student}`, body: `${row.sender}: ${clip(row.body, 100)}`,
      data: { kind: e.kind, thread_id: threadId },
    }];
  },

  async 'payment.succeeded'(tx, e) {
    if (!e.ref_id || !e.student_id) return [];
    const r = await tx.query<{ amount: string; description: string; student: string }>(
      `select p.amount, i.description, st.full_name as student from payments p
         join invoices i on i.id = p.invoice_id join people st on st.id = i.student_id where p.id = $1`,
      [e.ref_id],
    );
    const p = r.rows[0];
    if (!p) return [];
    const text = `${cedi(p.amount)} received for ${p.student}'s ${p.description}. Thank you.`;
    return (await guardiansOfStudent(tx, e.student_id)).map((personId) => ({
      personId, title: 'Payment received', body: text,
      data: { kind: e.kind, payment_id: e.ref_id! },
      email: { subject: 'Receipt from Homeroom', text: `${text}\n\nReference: ${e.ref_id}` },
    }));
  },

  async 'fees.due_soon'(tx, e) {
    if (!e.ref_id || !e.student_id) return [];
    const r = await tx.query<{ owed: string; due_date: string; description: string; student: string }>(
      `select i.amount_due - coalesce((select sum(p.amount) from payments p where p.invoice_id = i.id and p.status = 'succeeded'), 0) as owed,
              i.due_date, i.description, st.full_name as student
         from invoices i join people st on st.id = i.student_id where i.id = $1`,
      [e.ref_id],
    );
    const i = r.rows[0];
    if (!i || Number(i.owed) <= 0) return [];
    return (await guardiansOfStudent(tx, e.student_id)).map((personId) => ({
      personId, title: 'Fees due soon',
      body: `${cedi(i.owed)} for ${i.student}'s ${i.description} is due ${longDate(i.due_date)}.`,
      data: { kind: e.kind, invoice_id: e.ref_id! },
    }));
  },
};

export async function expand(tx: Tx, e: OutboxEvent): Promise<Draft[]> {
  const h = handlers[e.kind];
  return h ? h(tx, e) : [];
}

export const knownKinds = Object.keys(handlers);
