import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { newRefreshToken } from '../src/auth/tokens.ts';
import { id, setup, type Harness } from './support/harness.ts';

let h: Harness;
before(async () => {
  h = await setup();
});
after(async () => {
  await h.close();
});

/** Mirrors what `node src/cli.ts create-invite` does, without shelling out. */
async function mintInvite(opts: { expiresInMs?: number } = {}): Promise<string> {
  const { token, hash } = newRefreshToken();
  const expiresAt = new Date(h.clock.now().getTime() + (opts.expiresInMs ?? 14 * 24 * 3600 * 1000));
  await h.db.asService((tx) => tx.query('insert into school_invites (code_hash, expires_at) values ($1, $2)', [hash, expiresAt]));
  return token;
}

describe('school onboarding', () => {
  test('a valid code creates a school and its admin, and cannot be reused', async () => {
    const code = await mintInvite();
    h.email.clear();
    const r = await h.call('POST', '/schools', {
      json: {
        invite_code: code,
        school_name: 'Sunrise Montessori',
        admin: { full_name: 'Adwoa Mensah', email: 'adwoa@sunrise.example' },
      },
    });
    assert.equal(r.status, 201);
    assert.equal(r.body.name, 'Sunrise Montessori');
    assert.equal(r.body.timezone, 'Africa/Accra'); // default

    // the admin got a set-password email, same as POST /people with invite: true
    assert.equal(h.email.sent.length, 1);
    assert.equal(h.email.sent[0]!.to, 'adwoa@sunrise.example');
    assert.match(h.email.sent[0]!.text, /reset\?token=/);

    const replay = await h.call('POST', '/schools', {
      json: { invite_code: code, school_name: 'Second Try', admin: { full_name: 'X', email: 'x@example.com' } },
    });
    assert.equal(replay.status, 400);
    assert.equal(replay.body.code, 'invalid_invite_code');
  });

  test('an unknown code is rejected', async () => {
    const r = await h.call('POST', '/schools', {
      json: { invite_code: 'not-a-real-code', school_name: 'Nope Academy', admin: { full_name: 'X', email: 'x@example.com' } },
    });
    assert.equal(r.status, 400);
    assert.equal(r.body.code, 'invalid_invite_code');
  });

  test('an expired code is rejected', async () => {
    const code = await mintInvite({ expiresInMs: 1000 });
    h.clock.advance(2000);
    const r = await h.call('POST', '/schools', {
      json: { invite_code: code, school_name: 'Too Late Academy', admin: { full_name: 'X', email: 'x@example.com' } },
    });
    assert.equal(r.status, 400);
    assert.equal(r.body.code, 'invalid_invite_code');
    h.clock.advance(-2000);
  });

  test('the admin needs an email or a phone', async () => {
    const code = await mintInvite();
    const r = await h.call('POST', '/schools', {
      json: { invite_code: code, school_name: 'No Contact Academy', admin: { full_name: 'X' } },
    });
    assert.equal(r.status, 400);
    assert.equal(r.body.code, 'validation_failed');
  });

  test('a school created through onboarding is isolated like any other tenant', async () => {
    const code = await mintInvite();
    h.email.clear();
    const created = await h.call('POST', '/schools', {
      json: {
        invite_code: code,
        school_name: 'Isolated Academy',
        admin: { full_name: 'Yaw Boateng', email: 'yaw@isolated.example' },
      },
    });
    assert.equal(created.status, 201);

    const [, hash] = h.email.sent[0]!.text.match(/token=(\S+)/)!;
    await h.call('POST', '/auth/password/reset', { json: { token: hash, new_password: 'a-new-password-1' } });
    const signIn = await h.call('POST', '/auth/sessions', { json: { email: 'yaw@isolated.example', password: 'a-new-password-1' } });
    assert.equal(signIn.status, 200);
    assert.equal(signIn.body.session.me.role, 'admin');
    assert.equal(signIn.body.session.me.school.name, 'Isolated Academy');
    assert.notEqual(signIn.body.session.me.school.id, id('school:greenfield'));

    // the new admin sees only themself, nothing from the seeded demo school
    const people = await h.call('GET', '/people', { as: signIn.body.session.access_token });
    assert.deepEqual(people.body.items.map((p: { full_name: string }) => p.full_name), ['Yaw Boateng']);

    // and an existing admin sees nothing from the freshly onboarded one
    const esiPeople = await h.call('GET', '/people', { as: await h.login('esi') });
    assert.ok(!esiPeople.body.items.some((p: { full_name: string }) => p.full_name === 'Yaw Boateng'));
  });
});
