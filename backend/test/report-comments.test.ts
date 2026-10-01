import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => { h = await setup(); });
after(async () => { await h.close(); });

const six = id('sec:6A'); // term open
const closedSection = id('sec:5A25'); // term closed, Kwame teaches Maths, Kofi completed it

describe('report comments', () => {
  test('a teacher drafts a comment; it shows up on the roster sheet', async () => {
    const as = await h.login('kwame');
    const empty = await h.call('GET', `/class_sections/${six}/comments?subject=Maths`, { as });
    assert.equal(empty.status, 200);
    const kofiRow = empty.body.items.find((x: any) => x.student.full_name === 'Kofi Asante');
    assert.equal(kofiRow.body, null);

    const saved = await h.call('PATCH', `/class_sections/${six}/comments`, {
      as, json: { subject: 'Maths', comments: [{ student_id: id('p:kofi'), body: 'Working hard on fractions.' }] },
    });
    assert.equal(saved.status, 200);
    assert.deepEqual([saved.body.applied, saved.body.rejected], [1, 0]);

    const after_ = await h.call('GET', `/class_sections/${six}/comments?subject=Maths`, { as });
    const row = after_.body.items.find((x: any) => x.student.full_name === 'Kofi Asante');
    assert.equal(row.body, 'Working hard on fractions.');
    assert.ok(row.updated_at);
  });

  test('a guardian cannot see it while the term is still open', async () => {
    const r = await h.call('GET', `/students/${id('p:kofi')}/report_comments`, { as: await h.login('akua') });
    assert.equal(r.status, 200);
    assert.deepEqual(r.body.items, []);
  });

  test('admin can always view, but cannot write', async () => {
    const view = await h.call('GET', `/class_sections/${six}/comments?subject=Maths`, { as: await h.login('esi') });
    assert.equal(view.status, 200);
    const write = await h.call('PATCH', `/class_sections/${six}/comments`, {
      as: await h.login('esi'), json: { subject: 'Maths', comments: [{ student_id: id('p:kofi'), body: 'x' }] },
    });
    assert.equal(write.status, 403);
  });

  test('a teacher cannot write for a section they do not teach: rejected per-row, not thrown', async () => {
    const r = await h.call('PATCH', `/class_sections/${closedSection}/comments`, {
      as: await h.login('yaw'), json: { subject: 'Maths', comments: [{ student_id: id('p:kofi'), body: 'x' }] },
    });
    assert.equal(r.status, 200);
    assert.deepEqual([r.body.applied, r.body.rejected], [0, 1]);
    assert.equal(r.body.results[0].code, 'not_enrolled');
  });

  test('once the term closes, a comment written earlier becomes visible to the guardian; the teacher can no longer edit it', async () => {
    // Simulate a comment drafted before the term closed (the teacher cannot write to a closed term through the API).
    await h.db.asService((tx) =>
      tx.query(
        `insert into report_comments (school_id, student_id, class_section_id, subject, teacher_id, body)
         values ($1, $2, $3, 'Maths', $4, 'A strong term in mathematics.')`,
        [id('school:greenfield'), id('p:kofi'), closedSection, id('p:kwame')],
      ),
    );

    const guardianView = await h.call('GET', `/students/${id('p:kofi')}/report_comments`, { as: await h.login('akua') });
    assert.equal(guardianView.status, 200);
    const item = guardianView.body.items.find((x: any) => x.class_section_id === closedSection);
    assert.equal(item.body, 'A strong term in mathematics.');
    assert.equal(item.teacher.full_name, 'Kwame Boateng');

    const edit = await h.call('PATCH', `/class_sections/${closedSection}/comments`, {
      as: await h.login('kwame'), json: { subject: 'Maths', comments: [{ student_id: id('p:kofi'), body: 'edited' }] },
    });
    assert.equal(edit.status, 200);
    assert.deepEqual([edit.body.applied, edit.body.rejected], [0, 1]);
    assert.equal(edit.body.results[0].code, 'not_enrolled');

    await h.db.asService((tx) => tx.query(`delete from report_comments where class_section_id = $1`, [closedSection]));
  });

  test('a nonexistent student in the batch is reported, not thrown', async () => {
    const r = await h.call('PATCH', `/class_sections/${six}/comments`, {
      as: await h.login('kwame'),
      json: { subject: 'Maths', comments: [{ student_id: '00000000-0000-0000-0000-000000000000', body: 'x' }] },
    });
    assert.equal(r.status, 200);
    assert.deepEqual([r.body.applied, r.body.rejected], [0, 1]);
    assert.equal(r.body.results[0].code, 'unknown_student');
    await h.db.asService((tx) => tx.query(`delete from report_comments where class_section_id = $1`, [six]));
  });
});
