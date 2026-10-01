import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { EMAILS, PASSWORD, id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => {
  h = await setup();
});
after(async () => {
  await h.close();
});

describe('health', () => {
  test('liveness and readiness', async () => {
    const live = await h.app.request('/healthz');
    assert.equal(live.status, 200);
    const ready = await h.app.request('/readyz');
    assert.deepEqual(await ready.json(), { status: 'ready' });
  });

  test('every response carries a request id, and a supplied one is echoed', async () => {
    const r = await h.app.request('/healthz', { headers: { 'x-request-id': 'trace-abc-12345' } });
    assert.equal(r.headers.get('x-request-id'), 'trace-abc-12345');
    const r2 = await h.app.request('/healthz');
    assert.match(r2.headers.get('x-request-id') ?? '', /^[0-9a-f-]{36}$/);
  });
});

describe('errors', () => {
  test('unauthenticated request is a 401 problem document with a code and request id', async () => {
    const r = await h.call('GET', '/me');
    assert.equal(r.status, 401);
    assert.equal(r.body.code, 'unauthorized');
    assert.ok(r.body.request_id);
    assert.equal(r.headers.get('content-type'), 'application/problem+json');
  });

  test('malformed JSON and wrong shapes are 400s with field errors', async () => {
    const bad = await h.call('POST', '/auth/sessions', { raw: '{nope', headers: { 'content-type': 'application/json' } });
    assert.equal(bad.status, 400);
    assert.equal(bad.body.code, 'invalid_json');
    const shape = await h.call('POST', '/auth/sessions', { json: { email: 'not-an-email' } });
    assert.equal(shape.status, 400);
    assert.equal(shape.body.code, 'validation_failed');
    assert.ok(shape.body.errors.some((e: { field: string }) => e.field === 'email'));
  });

  test('unknown route is a problem document, not HTML', async () => {
    const r = await h.call('GET', '/nope', { as: await h.login('akua'), noContract: true });
    assert.equal(r.status, 404);
    assert.equal(r.body.code, 'not_found');
  });
});

describe('sign in', () => {
  test('correct credentials return a session with the caller', async () => {
    const r = await h.call('POST', '/auth/sessions', { json: { email: EMAILS.akua, password: PASSWORD } });
    assert.equal(r.status, 200);
    assert.equal(r.body.status, 'signed_in');
    assert.equal(r.body.session.me.role, 'guardian');
    assert.equal(r.body.session.me.full_name, 'Akua Asante');
    assert.equal(r.body.session.expires_in, 900);
  });

  test('wrong password and unknown email give the same answer', async () => {
    const a = await h.call('POST', '/auth/sessions', { json: { email: EMAILS.akua, password: 'wrong' } });
    const b = await h.call('POST', '/auth/sessions', { json: { email: 'nobody@example.com', password: 'wrong' } });
    assert.equal(a.status, 401);
    assert.equal(b.status, 401);
    assert.equal(a.body.code, 'invalid_credentials');
    assert.equal(a.body.detail, b.body.detail);
  });

  test('email is case-insensitive', async () => {
    const r = await h.call('POST', '/auth/sessions', { json: { email: EMAILS.kwame.toUpperCase(), password: PASSWORD } });
    assert.equal(r.status, 200);
  });

  test('a disabled account cannot sign in', async () => {
    await h.db.asService((tx) => tx.query(`update accounts set disabled_at = now() where email = $1`, [EMAILS.comfort]));
    const r = await h.call('POST', '/auth/sessions', { json: { email: EMAILS.comfort, password: PASSWORD } });
    assert.equal(r.status, 401);
    await h.db.asService((tx) => tx.query(`update accounts set disabled_at = null where email = $1`, [EMAILS.comfort]));
  });
});

describe('GET /me', () => {
  test('guardian gets a child switcher, sorted, with each child\'s section', async () => {
    const r = await h.call('GET', '/me', { as: await h.login('akua') });
    assert.deepEqual(
      r.body.children.map((c: { full_name: string; class_section: { name: string } }) => [c.full_name, c.class_section.name]),
      [['Ama Asante', '4B'], ['Kofi Asante', '6A']],
    );
    assert.equal(r.body.sections, undefined);
  });

  test('teacher gets the sections they teach, with their subjects, current term only', async () => {
    const r = await h.call('GET', '/me', { as: await h.login('kwame') });
    assert.equal(r.body.sections.length, 1); // the closed-term 5A section is hidden
    assert.equal(r.body.sections[0].name, '6A');
    assert.equal(r.body.sections[0].subject, 'Homeroom, Maths');
    const yaw = await h.call('GET', '/me', { as: await h.login('yaw') });
    assert.deepEqual(yaw.body.sections.map((s: { name: string }) => s.name), ['6A', '6B']);
  });

  test('admin gets school details and no children or sections', async () => {
    const r = await h.call('GET', '/me', { as: await h.login('esi') });
    assert.equal(r.body.role, 'admin');
    assert.equal(r.body.school.name, 'Greenfield Academy');
    assert.equal(r.body.children, undefined);
  });
});

describe('tokens', () => {
  test('an expired access token is rejected with a specific code', async () => {
    const token = await h.login('nana');
    h.clock.advance(16 * 60 * 1000);
    const r = await h.call('GET', '/me', { as: token });
    assert.equal(r.status, 401);
    assert.equal(r.body.code, 'token_expired');
    h.clock.advance(-16 * 60 * 1000);
  });

  test('a tampered token is rejected', async () => {
    const token = await h.login('nana');
    const r = await h.call('GET', '/me', { as: token.slice(0, -4) + 'AAAA' });
    assert.equal(r.status, 401);
    assert.equal(r.body.code, 'invalid_token');
  });

  test('refresh rotates; reusing an old token revokes the whole session', async () => {
    const s = await h.call('POST', '/auth/sessions', { json: { email: EMAILS.efua, password: PASSWORD } });
    const first = s.body.session.refresh_token as string;
    const second = await h.call('POST', '/auth/refresh', { json: { refresh_token: first } });
    assert.equal(second.status, 200);
    assert.notEqual(second.body.refresh_token, first);

    const replay = await h.call('POST', '/auth/refresh', { json: { refresh_token: first } });
    assert.equal(replay.status, 401);
    assert.equal(replay.body.code, 'refresh_token_reused');

    // the legitimate holder of the newer token is logged out too: theft response
    const after = await h.call('POST', '/auth/refresh', { json: { refresh_token: second.body.refresh_token } });
    assert.equal(after.status, 401);
  });

  test('sign-out revokes the session', async () => {
    const s = await h.call('POST', '/auth/sessions', { json: { email: EMAILS.samuel, password: PASSWORD } });
    const out = await h.call('DELETE', '/auth/sessions/current', { as: s.body.session.access_token });
    assert.equal(out.status, 204);
    const r = await h.call('POST', '/auth/refresh', { json: { refresh_token: s.body.session.refresh_token } });
    assert.equal(r.status, 401);
  });

  test('garbage refresh token is a plain 401', async () => {
    const r = await h.call('POST', '/auth/refresh', { json: { refresh_token: 'x'.repeat(20) } });
    assert.equal(r.status, 401);
    assert.equal(r.body.code, 'invalid_refresh_token');
  });
});

describe('sms code sign-in (guardians)', () => {
  const lastCode = () => /(\d{6})/.exec(h.sms.sent.at(-1)?.text ?? '')?.[1] ?? '';

  test('a code is sent to the normalised number and signs the guardian in', async () => {
    h.sms.clear();
    const req = await h.call('POST', '/auth/otp', { json: { phone: '024 000 0003' } }); // Nana Adjei
    assert.equal(req.status, 204);
    assert.equal(h.sms.sent.length, 1);
    assert.equal(h.sms.sent[0]!.to, '+233240000003');
    const r = await h.call('POST', '/auth/otp/verify', { json: { phone: '0240000003', code: lastCode() } });
    assert.equal(r.status, 200);
    assert.equal(r.body.session.me.full_name, 'Nana Adjei');
  });

  test('a code works once', async () => {
    h.sms.clear();
    await h.call('POST', '/auth/otp', { json: { phone: '0240000004' } });
    const code = lastCode();
    assert.equal((await h.call('POST', '/auth/otp/verify', { json: { phone: '0240000004', code } })).status, 200);
    assert.equal((await h.call('POST', '/auth/otp/verify', { json: { phone: '0240000004', code } })).status, 401);
  });

  test('an unknown number looks identical and sends nothing', async () => {
    h.sms.clear();
    const r = await h.call('POST', '/auth/otp', { json: { phone: '0200000999' } });
    assert.equal(r.status, 204);
    assert.equal(h.sms.sent.length, 0);
  });

  test('five wrong guesses lock the code, even the right one afterwards', async () => {
    h.sms.clear();
    await h.call('POST', '/auth/otp', { json: { phone: '0240000005' } });
    const real = lastCode();
    const wrong = real === '000000' ? '111111' : '000000';
    for (let i = 0; i < 5; i++) {
      const r = await h.call('POST', '/auth/otp/verify', { json: { phone: '0240000005', code: wrong } });
      assert.equal(r.status, 401);
      assert.equal(r.body.code, 'invalid_code');
    }
    assert.equal((await h.call('POST', '/auth/otp/verify', { json: { phone: '0240000005', code: real } })).status, 401);
  });

  test('a code expires after ten minutes', async () => {
    h.sms.clear();
    await h.call('POST', '/auth/otp', { json: { phone: '0240000002' } }); // Kwabena Asante
    const code = lastCode();
    h.clock.advance(11 * 60 * 1000);
    assert.equal((await h.call('POST', '/auth/otp/verify', { json: { phone: '0240000002', code } })).status, 401);
    h.clock.advance(-11 * 60 * 1000);
  });

  test('requests are capped per number per hour', async () => {
    for (let i = 0; i < 5; i++) await h.call('POST', '/auth/otp', { json: { phone: '0240000001' } });
    const r = await h.call('POST', '/auth/otp', { json: { phone: '0240000001' } });
    assert.equal(r.status, 429);
    assert.equal(r.body.code, 'rate_limited');
  });
});

describe('an account that holds several roles', () => {
  test('sign-in asks which role; choosing one signs in as that person; a foreign id is refused', async () => {
    // Esi is also a parent at the school: a second person row on the same account.
    const extra = id('p:esi-as-parent');
    await h.db.asService(async (tx) => {
      const acct = await tx.query<{ id: string }>(`select id from accounts where email = $1`, [EMAILS.esi]);
      await tx.query(
        `insert into people (id, school_id, full_name, role, auth_user_id) values ($1, $2, 'Esi Mensah', 'guardian', $3)`,
        [extra, id('school:greenfield'), acct.rows[0]!.id],
      );
    });
    const r = await h.call('POST', '/auth/sessions', { json: { email: EMAILS.esi, password: PASSWORD } });
    assert.equal(r.status, 200);
    assert.equal(r.body.status, 'selection_required');
    assert.deepEqual(r.body.selection.choices.map((c: { role: string }) => c.role).sort(), ['admin', 'guardian']);

    const pick = await h.call('POST', '/auth/sessions/select', {
      json: { selection_token: r.body.selection.selection_token, person_id: extra },
    });
    assert.equal(pick.status, 200);
    assert.equal(pick.body.me.role, 'guardian');

    const foreign = await h.call('POST', '/auth/sessions/select', {
      json: { selection_token: r.body.selection.selection_token, person_id: id('p:akua') },
    });
    assert.equal(foreign.status, 403);
    assert.equal(foreign.body.code, 'invalid_selection');

    // cleanup so later tests see the original single-role Esi
    await h.db.asService(async (tx) => {
      await tx.query(`delete from refresh_tokens where person_id = $1`, [extra]);
      await tx.query(`delete from people where id = $1`, [extra]);
    });
  });
});

describe('idempotency', () => {
  const push = { token: 'fcm-token-0123456789', platform: 'android' };

  test('a repeated key replays the stored response; a different body under the same key is refused', async () => {
    const as = await h.login('akua');
    const key = { 'idempotency-key': 'key-push-1' };
    const a = await h.call('POST', '/me/push_tokens', { as, json: push, headers: key });
    assert.equal(a.status, 204);
    const b = await h.call('POST', '/me/push_tokens', { as, json: push, headers: key });
    assert.equal(b.status, 204);
    assert.equal(b.headers.get('idempotent-replay'), 'true');
    const c = await h.call('POST', '/me/push_tokens', { as, json: { ...push, platform: 'ios' }, headers: key });
    assert.equal(c.status, 422);
    assert.equal(c.body.code, 'idempotency_key_reused');
  });
});

describe('notification preferences and contact', () => {
  test('prefs default on, can be replaced, and persist', async () => {
    const as = await h.login('kwabena');
    assert.deepEqual((await h.call('GET', '/me/notification_prefs', { as })).body, { push: true, email: true, sms: true });
    const put = await h.call('PUT', '/me/notification_prefs', { as, json: { push: false, email: true, sms: true } });
    assert.equal(put.status, 200);
    assert.equal((await h.call('GET', '/me/notification_prefs', { as })).body.push, false);
  });

  test('a person edits their own contact; omitted fields are kept, null clears', async () => {
    const as = await h.login('nana');
    const a = await h.call('PUT', '/me/contact', { as, json: { email: 'Nana.Adjei@Example.com' } });
    assert.deepEqual(a.body, { phone: '+233240000003', email: 'nana.adjei@example.com' });
    const b = await h.call('PUT', '/me/contact', { as, json: { phone: '024 555 0100', email: null } });
    assert.deepEqual(b.body, { phone: '+233245550100', email: null });
  });
});
