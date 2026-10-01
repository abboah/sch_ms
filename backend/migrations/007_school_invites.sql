-- 007: school onboarding. A one-time invite code (minted by an operator via
-- `node src/cli.ts create-invite`) lets a new school create itself and its first
-- admin through POST /schools, with no login and no new role needed.
--
-- SERVICE ONLY, same as accounts/refresh_tokens/otp_codes: no grant to app_user at
-- all, so a signed-in user can never read, forge, or reuse a code even through a
-- bug in the API. Only the code's hash is stored, same as refresh_tokens and
-- password_resets.
create table school_invites (
  id                uuid primary key default gen_random_uuid(),
  code_hash         text not null unique,
  expires_at        timestamptz not null,
  used_at           timestamptz,
  used_by_school_id uuid references schools (id),
  created_at        timestamptz not null default now()
);
