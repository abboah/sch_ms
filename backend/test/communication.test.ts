import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => { h = await setup(); });
after(async () => { await h.close(); });

const titles = (r: any) => r.body.items.map((a: any) => a.title);

describe('messaging', () => {
  const kofiThread = id('thr:kofi');

  test('each side sees the thread with its last message and their own unread count', async () => {
    const akua = await h.call('GET', '/threads', { as: await h.login('akua') });
    assert.equal(akua.body.items.length, 1);
    const t = akua.body.items[0];
    assert.equal(t.student.full_name, 'Kofi Asante');
    assert.equal(t.teacher.full_name, 'Kwame Boateng');
    assert.match(t.last_message.body, /^Thanks, marked excused/);
    assert.equal(t.unread, 1); // Kwame's reply
    assert.equal((await h.call('GET', '/threads', { as: await h.login('kwame') })).body.items[0].unread, 1); // Akua's message
  });

  test('other families, other teachers see nothing; the administrator audits with no unread badge', async () => {
    assert.equal((await h.call('GET', '/threads', { as: await h.login('samuel') })).body.items.length, 0);
    assert.equal((await h.call('GET', '/threads', { as: await h.login('abena') })).body.items.length, 0);
    const esi = await h.call('GET', '/threads', { as: await h.login('esi') });
    assert.deepEqual([esi.body.items.length, esi.body.items[0].unread], [1, 0]);
  });

  test('reading clears the badge; a new message brings it back', async () => {
    const akua = await h.login('akua');
    assert.equal((await h.call('POST', `/threads/${kofiThread}/read`, { as: akua })).status, 204);
    assert.equal((await h.call('GET', '/threads', { as: akua })).body.items[0].unread, 0);
    h.clock.advance(60_000);
    await h.call('POST', `/threads/${kofiThread}/messages`, { as: await h.login('kwame'), json: { body: 'Worksheet is on the class page.' } });
    assert.equal((await h.call('GET', '/threads', { as: akua })).body.items[0].unread, 1);
  });

  test('messages read oldest first and page; sending is for the two participants only', async () => {
    const as = await h.login('akua');
    const p1 = await h.call('GET', `/threads/${kofiThread}/messages?limit=2`, { as });
    assert.equal(p1.body.items.length, 2);
    assert.match(p1.body.items[0].body, /^Kofi was out Friday/);
    const p2 = await h.call('GET', `/threads/${kofiThread}/messages?limit=2&cursor=${p1.body.next_cursor}`, { as });
    assert.equal(p2.body.items.length, 1);
    assert.equal(p2.body.next_cursor, null);

    const sent = await h.call('POST', `/threads/${kofiThread}/messages`, { as, json: { body: '  Thank you!  ' } });
    assert.equal(sent.status, 201);
    assert.equal(sent.body.body, 'Thank you!'); // trimmed
    assert.equal((await h.call('POST', `/threads/${kofiThread}/messages`, { as, json: { body: '   ' } })).status, 400);
    assert.equal((await h.call('POST', `/threads/${kofiThread}/messages`, { as: await h.login('samuel'), json: { body: 'hi' } })).status, 404);
    const admin = await h.call('POST', `/threads/${kofiThread}/messages`, { as: await h.login('esi'), json: { body: 'hi' } });
    assert.equal(admin.status, 403);
    assert.equal(admin.body.code, 'not_a_participant');
    assert.equal((await h.call('GET', `/threads/${kofiThread}/messages`, { as: await h.login('esi') })).status, 200);
  });

  test('sending queues a notification for the other side', async () => {
    const q = await h.db.asService((tx) => tx.query(`select count(*)::int n from notification_outbox where kind = 'message.sent'`));
    assert.ok(q.rows[0]!.n >= 2);
  });

  test('a thread is only ever about a child both people share', async () => {
    const open = (who: string, student: string, other: string) =>
      h.call('POST', '/threads', { as: who, json: { student_id: id(student), other_party_id: id(other) } });
    const nana = await h.login('nana');
    const made = await open(nana, 'p:yaa', 'p:kwame');
    assert.equal(made.status, 201);
    assert.equal(made.body.teacher.full_name, 'Kwame Boateng');
    const again = await open(nana, 'p:yaa', 'p:kwame');
    assert.equal(again.status, 200);
    assert.equal(again.body.id, made.body.id);
    assert.equal((await open(nana, 'p:yaa', 'p:abena')).body.code, 'not_a_shared_child'); // Abena does not teach Yaa
    assert.equal((await open(nana, 'p:kofi', 'p:kwame')).status, 403);                    // not her child
    assert.equal((await open(await h.login('kwame'), 'p:kojot', 'p:samuel')).status, 403); // Kwame does not teach Kojo
    const fromTeacher = await open(await h.login('kwame'), 'p:yaa', 'p:nana');
    assert.equal(fromTeacher.body.id, made.body.id, 'the same thread whichever side starts it');
    assert.equal((await open(await h.login('esi'), 'p:yaa', 'p:nana')).status, 403);
  });
});

describe('announcements', () => {
  test('parents see published notices for the school or their child\'s class, never drafts or other classes', async () => {
    const akua = await h.call('GET', '/announcements', { as: await h.login('akua') });
    assert.deepEqual(titles(akua), ['Science museum trip', 'Mid-term break']);
    const samuel = await h.call('GET', '/announcements', { as: await h.login('samuel') });
    assert.deepEqual(titles(samuel), ['English reading', 'Science museum trip', 'Mid-term break']);
    assert.equal(samuel.body.items[0].author.full_name, 'Abena Owusu');
    assert.equal(samuel.body.items[2].author, undefined, 'an admin author the parent cannot see is omitted, not leaked');
  });

  test('admin also sees drafts', async () => {
    const r = await h.call('GET', '/announcements', { as: await h.login('esi') });
    assert.ok(titles(r).includes('Term 2 fees notice'));
    assert.equal(r.body.items.find((a: any) => a.title === 'Term 2 fees notice').published_at, null);
  });

  test('a teacher can post to a class they teach, not to the whole school or another class', async () => {
    const as = await h.login('kwame');
    const ok = await h.call('POST', '/announcements', { as, json: { title: 'Maths club', body: 'Thursday lunch.', class_section_id: id('sec:6A'), published: true } });
    assert.equal(ok.status, 201);
    assert.ok(ok.body.published_at);
    assert.ok(titles(await h.call('GET', '/announcements', { as: await h.login('akua') })).includes('Maths club'));
    assert.ok(!titles(await h.call('GET', '/announcements', { as: await h.login('samuel') })).includes('Maths club'));
    const school = await h.call('POST', '/announcements', { as, json: { title: 'x', body: 'y', published: true } });
    assert.equal(school.status, 403);
    assert.equal(school.body.code, 'cannot_post_here');
    assert.equal((await h.call('POST', '/announcements', { as, json: { title: 'x', body: 'y', class_section_id: id('sec:6B'), published: true } })).status, 403);
    assert.equal((await h.call('POST', '/announcements', { as: await h.login('akua'), json: { title: 'x', body: 'y' } })).status, 403);
  });

  test('a draft is invisible until published; only its author or an admin can publish it, and publishing notifies', async () => {
    const kwame = await h.login('kwame');
    const draft = await h.call('POST', '/announcements', { as: kwame, json: { title: 'Field trip?', body: 'Thoughts?', class_section_id: id('sec:6A') } });
    assert.equal(draft.body.published_at, null);
    assert.ok(!titles(await h.call('GET', '/announcements', { as: await h.login('akua') })).includes('Field trip?'));
    assert.equal((await h.call('POST', `/announcements/${draft.body.id}/publish`, { as: await h.login('yaw') })).status, 404); // cannot even see it
    const pub = await h.call('POST', `/announcements/${draft.body.id}/publish`, { as: kwame });
    assert.ok(pub.body.published_at);
    const again = await h.call('POST', `/announcements/${draft.body.id}/publish`, { as: kwame });
    assert.equal(again.body.published_at, pub.body.published_at, 'publishing twice is harmless');
    assert.ok(titles(await h.call('GET', '/announcements', { as: await h.login('akua') })).includes('Field trip?'));
    const q = await h.db.asService((tx) => tx.query(`select count(*)::int n from notification_outbox where kind = 'announcement.published' and ref_id = $1`, [draft.body.id]));
    assert.equal(q.rows[0]!.n, 1);
  });

  test('permission slips: either parent replies per child; replies can be changed; tallies count the rest as awaiting', async () => {
    const trip = id('ann:trip');
    const akua = await h.login('akua');
    const yes = await h.call('PUT', `/announcements/${trip}/responses`, { as: akua, json: { student_id: id('p:kofi'), response: 'yes' } });
    assert.equal(yes.body.response, 'yes');
    const dad = await h.call('PUT', `/announcements/${trip}/responses`, { as: await h.login('kwabena'), json: { student_id: id('p:kofi'), response: 'no' } });
    assert.deepEqual([dad.body.response, dad.body.guardian_id], ['no', id('p:kwabena')]);
    const mine = await h.call('GET', '/announcements', { as: akua });
    assert.deepEqual(mine.body.items.find((a: any) => a.title === 'Science museum trip').my_responses.map((x: any) => x.response), ['no']);

    const tally = await h.call('GET', `/announcements/${trip}/responses`, { as: await h.login('esi') });
    assert.deepEqual([tally.body.yes, tally.body.no, tally.body.awaiting], [0, 1, 64]);
  });

  test('replying is for your own child and only when a reply is asked for', async () => {
    const akua = await h.login('akua');
    const other = await h.call('PUT', `/announcements/${id('ann:trip')}/responses`, { as: akua, json: { student_id: id('p:yaa'), response: 'yes' } });
    assert.equal(other.status, 403);
    assert.equal(other.body.code, 'not_your_child');
    const none = await h.call('PUT', `/announcements/${id('ann:break')}/responses`, { as: akua, json: { student_id: id('p:kofi'), response: 'yes' } });
    assert.equal(none.body.code, 'no_response_expected');
    assert.equal((await h.call('GET', `/announcements/${id('ann:trip')}/responses`, { as: akua })).status, 403);
  });
});

describe('homework', () => {
  test('a teacher posts to their class; it shows on the pupil\'s list with the subject, and queues a notification', async () => {
    const as = await h.login('kwame');
    const r = await h.call('POST', `/class_sections/${id('sec:6A')}/homework`, { as, json: { title: 'Fractions sheet', body: 'Q1 to Q10', due_date: '2026-10-12' } });
    assert.equal(r.status, 201);
    assert.equal(r.body.subject, 'Maths');
    assert.equal(r.body.posted_by.full_name, 'Kwame Boateng');
    const kids = await h.call('GET', `/students/${id('p:kofi')}/homework`, { as: await h.login('akua') });
    assert.deepEqual(kids.body.items.map((x: any) => x.title), ['Exercises 4.2 to 4.5', 'Fractions sheet']);
    const later = await h.call('GET', `/students/${id('p:kofi')}/homework?due_from=2026-10-10`, { as: await h.login('akua') });
    assert.deepEqual(later.body.items.map((x: any) => x.title), ['Fractions sheet']);
    const q = await h.db.asService((tx) => tx.query(`select count(*)::int n from notification_outbox where kind = 'homework.posted'`));
    assert.ok(q.rows[0]!.n >= 1);
  });

  test('not for other classes, closed terms or parents; a class list is staff only', async () => {
    const body = { title: 'x', due_date: '2026-10-12' };
    assert.equal((await h.call('POST', `/class_sections/${id('sec:6A')}/homework`, { as: await h.login('abena'), json: body })).status, 404);
    assert.equal((await h.call('POST', `/class_sections/${id('sec:5A25')}/homework`, { as: await h.login('kwame'), json: body })).status, 403);
    assert.equal((await h.call('POST', `/class_sections/${id('sec:6A')}/homework`, { as: await h.login('akua'), json: body })).status, 403);
    assert.equal((await h.call('GET', `/class_sections/${id('sec:6A')}/homework`, { as: await h.login('akua') })).status, 403);
    const list = await h.call('GET', `/class_sections/${id('sec:6A')}/homework`, { as: await h.login('esi') });
    assert.ok(list.body.items.length >= 2);
  });

  test('another family\'s child is a 404', async () => {
    assert.equal((await h.call('GET', `/students/${id('p:kofi')}/homework`, { as: await h.login('samuel') })).status, 404);
  });
});

describe('parent-teacher conferences', () => {
  const slotAt = async (time: string) =>
    (await h.db.asService((tx) => tx.query(`select id from conference_slots where starts_at = $1`, [`2026-10-24 ${time}+00`]))).rows[0]!.id as string;

  test('parents see open slots of their child\'s teachers, plus their own booking', async () => {
    const nana = await h.call('GET', '/conference_slots', { as: await h.login('nana') });
    assert.equal(nana.body.items.length, 11); // 12 slots, Akua holds 09:15
    assert.ok(nana.body.items.every((s: any) => s.booked === false));
    const akua = await h.call('GET', '/conference_slots', { as: await h.login('akua') });
    assert.equal(akua.body.items.length, 12);
    const mine = akua.body.items.find((s: any) => s.booked_by_me);
    assert.equal(mine.student.full_name, 'Kofi Asante');
    assert.equal((await h.call('GET', '/conference_slots', { as: await h.login('samuel') })).body.items.length, 0);
  });

  test('book, rebook conflict, someone else\'s slot, a teacher who does not teach the child', async () => {
    const nana = await h.login('nana');
    const s0930 = await slotAt('09:30');
    const booked = await h.call('PUT', `/conference_slots/${s0930}/booking`, { as: nana, json: { student_id: id('p:yaa') } });
    assert.deepEqual([booked.body.booked, booked.body.booked_by_me, booked.body.student.full_name], [true, true, 'Yaa Adjei']);
    assert.equal((await h.call('PUT', `/conference_slots/${s0930}/booking`, { as: nana, json: { student_id: id('p:yaa') } })).status, 409);
    assert.equal((await h.call('PUT', `/conference_slots/${await slotAt('09:15')}/booking`, { as: nana, json: { student_id: id('p:yaa') } })).status, 409); // Akua's slot
    assert.equal((await h.call('PUT', `/conference_slots/${await slotAt('10:00')}/booking`, { as: await h.login('samuel'), json: { student_id: id('p:kojot') } })).status, 404);
    assert.equal((await h.call('PUT', `/conference_slots/${await slotAt('10:00')}/booking`, { as: nana, json: { student_id: id('p:kofi') } })).status, 404);
  });

  test('only the booker can release, and releasing twice is harmless', async () => {
    const s0930 = await slotAt('09:30');
    await h.call('DELETE', `/conference_slots/${s0930}/booking`, { as: await h.login('akua') }); // not hers: no effect
    let row = await h.db.asService((tx) => tx.query(`select booked_by_guardian_id from conference_slots where id = $1`, [s0930]));
    assert.equal(row.rows[0]!.booked_by_guardian_id, id('p:nana'));
    assert.equal((await h.call('DELETE', `/conference_slots/${s0930}/booking`, { as: await h.login('nana') })).status, 204);
    assert.equal((await h.call('DELETE', `/conference_slots/${s0930}/booking`, { as: await h.login('nana') })).status, 204);
    row = await h.db.asService((tx) => tx.query(`select booked_by_guardian_id from conference_slots where id = $1`, [s0930]));
    assert.equal(row.rows[0]!.booked_by_guardian_id, null);
  });

  test('a teacher creates slots from a window; repeating it adds nothing; limits are enforced', async () => {
    const as = await h.login('kwame');
    const win = { teacher_id: id('p:kwame'), starts_at: '2026-10-31T09:00:00Z', ends_at: '2026-10-31T10:00:00Z', slot_minutes: 20 };
    const made = await h.call('POST', '/conference_slots', { as, json: win });
    assert.equal(made.status, 201);
    assert.deepEqual(made.body.items.map((s: any) => s.starts_at.slice(11, 16)), ['09:00', '09:20', '09:40']);
    assert.equal((await h.call('POST', '/conference_slots', { as, json: win })).body.items.length, 0);
    assert.equal((await h.call('POST', '/conference_slots', { as, json: { ...win, ends_at: '2026-10-31T08:00:00Z' } })).body.code, 'invalid_window');
    assert.equal((await h.call('POST', '/conference_slots', { as, json: { ...win, ends_at: '2026-11-30T09:00:00Z', slot_minutes: 5 } })).body.code, 'too_many_slots');
    assert.equal((await h.call('POST', '/conference_slots', { as, json: { ...win, teacher_id: id('p:abena') } })).status, 403);
    assert.equal((await h.call('POST', '/conference_slots', { as: await h.login('akua'), json: win })).status, 403);
  });
});
