import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => { h = await setup(); });
after(async () => { await h.close(); });

const six = id('sec:6A');

describe('grade bands', () => {
  test('with none configured, gradebook and student summary show a bare number', async () => {
    const as = await h.login('kwame');
    const r = await h.call('GET', `/class_sections/${six}/gradebook`, { as });
    const kofi = r.body.rows.find((x: any) => x.student.full_name === 'Kofi Asante');
    assert.equal(kofi.running_grade, 74.5);
    assert.equal(kofi.grade_band, null);

    const summary = await h.call('GET', `/students/${id('p:kofi')}/summary`, { as: await h.login('akua') });
    assert.ok(summary.body.grades.every((g: any) => g.grade_band === null));
  });

  test('only admin manages the scale; everyone in the school can read it', async () => {
    assert.equal((await h.call('GET', '/grade_bands', { as: await h.login('kwame') })).status, 200);
    const denied = await h.call('POST', '/grade_bands', { as: await h.login('kwame'), json: { label: 'A', min_score: 80, max_score: 100 } });
    assert.equal(denied.status, 403);
  });

  test('admin defines a scale; it appears on the gradebook and student summary', async () => {
    const as = await h.login('esi');
    const a = await h.call('POST', '/grade_bands', { as, json: { label: 'A', min_score: 80, max_score: 100 } });
    assert.equal(a.status, 201);
    const b = await h.call('POST', '/grade_bands', { as, json: { label: 'B', min_score: 70, max_score: 79.9 } });
    assert.equal(b.status, 201);
    const c = await h.call('POST', '/grade_bands', { as, json: { label: 'C', min_score: 0, max_score: 69.9 } });
    assert.equal(c.status, 201);

    const listed = await h.call('GET', '/grade_bands', { as });
    assert.deepEqual(listed.body.items.map((x: any) => x.label), ['A', 'B', 'C']); // ordered by min_score desc

    const r = await h.call('GET', `/class_sections/${six}/gradebook`, { as: await h.login('kwame') });
    const kofi = r.body.rows.find((x: any) => x.student.full_name === 'Kofi Asante'); // running_grade 74.5
    assert.equal(kofi.grade_band, 'B');
    const kweku = r.body.rows.find((x: any) => x.student.full_name === 'Kweku Sarpong'); // no scores yet
    assert.equal(kweku.grade_band, null);

    const summary = await h.call('GET', `/students/${id('p:kofi')}/summary`, { as: await h.login('akua') });
    const maths = summary.body.grades.find((g: any) => g.subject === 'Maths');
    assert.equal(maths.grade_band, 'B');

    const grades = await h.call('GET', `/students/${id('p:kofi')}/grades`, { as: await h.login('akua') });
    const mathsSubject = grades.body.subjects.find((g: any) => g.subject === 'Maths');
    assert.equal(mathsSubject.grade_band, 'B');

    // cleanup so later tests in this file see a scale-free school again
    await h.db.asService((tx) => tx.query('delete from grade_bands where id = any($1::uuid[])', [[a.body.id, b.body.id, c.body.id]]));
  });

  test('a band cannot have min_score above max_score, on create or update', async () => {
    const as = await h.login('esi');
    const bad = await h.call('POST', '/grade_bands', { as, json: { label: 'Broken', min_score: 90, max_score: 10 } });
    assert.equal(bad.status, 422);
    assert.equal(bad.body.code, 'invalid_range');

    const ok = await h.call('POST', '/grade_bands', { as, json: { label: 'Pass', min_score: 50, max_score: 100 } });
    const patched = await h.call('PATCH', `/grade_bands/${ok.body.id}`, { as, json: { min_score: 101 } });
    assert.equal(patched.status, 422);
    assert.equal(patched.body.code, 'invalid_range');

    const del = await h.call('DELETE', `/grade_bands/${ok.body.id}`, { as });
    assert.equal(del.status, 204);
    assert.equal((await h.call('DELETE', `/grade_bands/${ok.body.id}`, { as })).status, 404);
  });

  test('a band from another school is invisible and unreachable', async () => {
    const riverside = await h.deps.tokens.signAccess(
      { personId: id('p:rb:admin'), role: 'admin', schoolId: id('school:riverside'), sessionId: randomUUID() },
      900,
    );
    const mine = await h.call('POST', '/grade_bands', { as: riverside, json: { label: 'X', min_score: 0, max_score: 100 } });
    assert.equal(mine.status, 201);
    const asGreenfield = await h.call('GET', '/grade_bands', { as: await h.login('esi') });
    assert.ok(!asGreenfield.body.items.some((b: any) => b.id === mine.body.id));
    assert.equal((await h.call('DELETE', `/grade_bands/${mine.body.id}`, { as: await h.login('esi') })).status, 404);
    await h.db.asService((tx) => tx.query('delete from grade_bands where id = $1', [mine.body.id]));
  });
});
