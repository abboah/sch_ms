// src/app.ts
import { Hono as Hono17 } from "hono";
import { bodyLimit } from "hono/body-limit";
import { cors } from "hono/cors";

// src/db/migrate.ts
import { createHash } from "node:crypto";
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
var MIGRATIONS_DIR = join(process.cwd(), "migrations");
function readMigrations(dir = MIGRATIONS_DIR) {
  return readdirSync(dir).filter((f) => f.endsWith(".sql")).sort().map((name) => {
    const sql = readFileSync(join(dir, name), "utf8");
    return { name, sql, checksum: createHash("sha256").update(sql).digest("hex") };
  });
}
async function migrate(db, dir = MIGRATIONS_DIR) {
  await db.asService(
    (tx) => tx.exec(`create table if not exists schema_migrations (
      name text primary key, checksum text not null, applied_at timestamptz not null default now())`)
  );
  const done = await db.asService(
    (tx) => tx.query("select name, checksum from schema_migrations")
  );
  const known = new Map(done.rows.map((r) => [r.name, r.checksum]));
  const applied = [];
  for (const m of readMigrations(dir)) {
    const prior = known.get(m.name);
    if (prior !== void 0) {
      if (prior !== m.checksum) {
        throw new Error(
          `Migration ${m.name} was edited after being applied. Migrations are append-only: revert the edit and add a new migration.`
        );
      }
      continue;
    }
    await db.asService(async (tx) => {
      await tx.exec(m.sql);
      await tx.query("insert into schema_migrations (name, checksum) values ($1, $2)", [m.name, m.checksum]);
    });
    applied.push(m.name);
  }
  return { applied };
}
async function migrationsCurrent(db, dir = MIGRATIONS_DIR) {
  const r = await db.asService((tx) => tx.query("select name from schema_migrations"));
  const have = new Set(r.rows.map((x) => x.name));
  return readMigrations(dir).every((m) => have.has(m.name));
}

// src/http/errors.ts
import { ZodError } from "zod";
var AppError = class extends Error {
  status;
  code;
  errors;
  constructor(status2, code, message, errors) {
    super(message);
    this.name = "AppError";
    this.status = status2;
    this.code = code;
    this.errors = errors;
  }
};
var badRequest = (message, code = "bad_request") => new AppError(400, code, message);
var unauthorized = (message = "Authentication required", code = "unauthorized") => new AppError(401, code, message);
var forbidden = (message = "You are not allowed to do that", code = "forbidden") => new AppError(403, code, message);
var notFound = (what = "Resource") => new AppError(404, "not_found", `${what} not found`);
var conflict = (message, code = "conflict") => new AppError(409, code, message);
var unprocessable = (message, code = "unprocessable") => new AppError(422, code, message);
var tooMany = (message = "Too many requests, slow down") => new AppError(429, "rate_limited", message);
var STATUS_TITLES = {
  400: "Bad request",
  401: "Unauthorized",
  403: "Forbidden",
  404: "Not found",
  409: "Conflict",
  422: "Unprocessable",
  429: "Too many requests",
  500: "Internal server error"
};
var title = (status2) => STATUS_TITLES[status2] ?? "Error";
function toProblem(err, requestId) {
  const base = (status2, code, detail, errors) => ({
    status: status2,
    title: title(status2),
    code,
    ...detail ? { detail } : {},
    ...errors ? { errors } : {},
    ...requestId ? { request_id: requestId } : {}
  });
  if (err instanceof AppError) return base(err.status, err.code, err.message, err.errors);
  if (err instanceof ZodError) {
    return base(
      400,
      "validation_failed",
      "The request did not match the expected shape",
      err.issues.map((i) => ({ field: i.path.join(".") || "(body)", message: i.message }))
    );
  }
  const e = err;
  switch (e?.code) {
    case "42501":
      return base(403, "forbidden", "You are not allowed to do that");
    case "HR409":
      return base(409, "conflict", e.message ?? "That is already taken");
    case "23505":
      return base(409, "already_exists", "That record already exists");
    case "23503":
      return base(409, "invalid_reference", "A referenced record does not exist or is not in your school");
    case "23514":
      return base(422, "constraint_violated", e.message ?? "A value is out of range");
    case "22P02":
    // invalid text representation (for example a malformed uuid)
    case "22007":
    case "22008":
      return base(400, "invalid_value", "A value is malformed");
    case "22003":
      return base(400, "out_of_range", "A numeric value is out of range");
  }
  return base(500, "internal_error", "Something went wrong on our side");
}

// src/http/middleware.ts
import { createHash as createHash2, randomUUID } from "node:crypto";
var REQUEST_ID_RE = /^[A-Za-z0-9._-]{8,64}$/;
function requestContext(deps2) {
  return async (c, next) => {
    const incoming = c.req.header("x-request-id");
    const requestId = incoming && REQUEST_ID_RE.test(incoming) ? incoming : randomUUID();
    const log = deps2.log.child({ requestId });
    c.set("requestId", requestId);
    c.set("log", log);
    c.header("x-request-id", requestId);
    const started = performance.now();
    await next();
    const ms = Math.round(performance.now() - started);
    const level = c.res.status >= 500 ? "error" : "info";
    log[level]("request", {
      method: c.req.method,
      path: c.req.path,
      status: c.res.status,
      ms,
      person: c.var.auth?.personId
    });
  };
}
function errorHandler() {
  return (err, c) => {
    const requestId = c.get("requestId");
    const problem = toProblem(err, requestId);
    if (problem.status >= 500) {
      (c.get("log") ?? console).error?.("unhandled error", { err });
    } else if (!(err instanceof AppError)) {
      c.get("log")?.debug("translated error", { code: problem.code, err });
    }
    return new Response(JSON.stringify(problem), {
      status: problem.status,
      headers: { "content-type": "application/problem+json", "x-request-id": requestId ?? "" }
    });
  };
}
function authenticate(deps2) {
  return async (c, next) => {
    const header = c.req.header("authorization") ?? "";
    const match = /^Bearer (.+)$/i.exec(header);
    if (!match) throw unauthorized();
    const claims = await deps2.tokens.verifyAccess(match[1]);
    c.set("auth", claims);
    await next();
  };
}
function requireRole(...roles) {
  return async (c, next) => {
    if (!roles.includes(c.var.auth.role)) throw new AppError(403, "forbidden", "Your role cannot use this endpoint");
    await next();
  };
}
function rateLimit(opts) {
  const hits = /* @__PURE__ */ new Map();
  return async (c, next) => {
    if (opts.limit <= 0) return next();
    const ip = c.req.header("x-forwarded-for")?.split(",")[0]?.trim() ?? "local";
    const key = `${opts.bucket}:${ip}`;
    const t = opts.now().getTime();
    const cur = hits.get(key);
    if (!cur || cur.resetAt <= t) {
      hits.set(key, { count: 1, resetAt: t + opts.windowMs });
    } else if (++cur.count > opts.limit) {
      c.header("retry-after", String(Math.ceil((cur.resetAt - t) / 1e3)));
      throw tooMany();
    }
    if (hits.size > 1e4) {
      for (const [k, v] of hits) if (v.resetAt <= t) hits.delete(k);
    }
    return next();
  };
}
function idempotency(deps2) {
  return async (c, next) => {
    const key = c.req.header("idempotency-key");
    if (!key || c.req.method === "GET") return next();
    if (key.length > 100) throw unprocessable("Idempotency-Key is too long", "invalid_idempotency_key");
    const personId = c.var.auth.personId;
    const body2 = await c.req.raw.clone().text();
    const hash = createHash2("sha256").update(`${c.req.method} ${c.req.path}
${body2}`).digest("hex");
    const claim = await deps2.db.asService(async (tx) => {
      const ins = await tx.query(
        `insert into idempotency_keys (person_id, key, request_hash, status) values ($1, $2, $3, 0)
         on conflict do nothing`,
        [personId, key, hash]
      );
      if (ins.rowCount === 1) return { state: "new" };
      const cur = await tx.query(
        "select request_hash, status, body from idempotency_keys where person_id = $1 and key = $2",
        [personId, key]
      );
      return { state: "existing", row: cur.rows[0] };
    });
    if (claim.state === "existing") {
      const { row } = claim;
      if (row.request_hash !== hash) {
        throw unprocessable("This Idempotency-Key was already used with a different request", "idempotency_key_reused");
      }
      if (row.status === 0) throw conflict("An identical request is still being processed", "request_in_progress");
      c.header("idempotent-replay", "true");
      return row.status === 204 || row.body == null ? c.body(null, row.status) : c.json(row.body, row.status);
    }
    let stored = false;
    try {
      await next();
      const res = c.res.clone();
      if (res.status < 500) {
        const text = await res.text();
        await deps2.db.asService(
          (tx) => tx.query("update idempotency_keys set status = $3, body = $4 where person_id = $1 and key = $2", [
            personId,
            key,
            res.status,
            text ? text : null
          ])
        );
        stored = true;
      }
    } finally {
      if (!stored) {
        await deps2.db.asService((tx) => tx.query("delete from idempotency_keys where person_id = $1 and key = $2", [personId, key])).catch(() => void 0);
      }
    }
  };
}

// src/modules/auth/routes.ts
import { Hono } from "hono";
import { z as z2 } from "zod";

// src/auth/service.ts
import { createHmac, randomInt, randomUUID as randomUUID2, timingSafeEqual as timingSafeEqual2 } from "node:crypto";

// src/modules/me/service.ts
async function loadMe(tx, personId, now) {
  const p = await tx.query(
    `select p.id, p.full_name, p.role, s.id as school_id, s.name as school_name, s.timezone
       from people p join schools s on s.id = p.school_id where p.id = $1`,
    [personId]
  );
  const row = p.rows[0];
  if (!row) throw notFound("Person");
  const me = {
    id: row.id,
    full_name: row.full_name,
    role: row.role,
    school: { id: row.school_id, name: row.school_name, timezone: row.timezone },
    now: now.toISOString()
  };
  const today = new Intl.DateTimeFormat("en-CA", { timeZone: row.timezone, year: "numeric", month: "2-digit", day: "2-digit" }).format(now);
  const term = await tx.query(
    "select id, name, starts_on, ends_on, closed from terms where $1::date between starts_on and ends_on order by starts_on desc limit 1",
    [today]
  );
  if (term.rows[0]) me.school.term = term.rows[0];
  const contact = await tx.query(
    "select phone, email from person_contacts where person_id = $1",
    [personId]
  );
  me.contact = contact.rows[0] ?? { phone: null, email: null };
  if (row.role === "guardian") {
    const kids = await tx.query(
      `select distinct on (st.id) st.id, st.full_name, cs.id as section_id, cs.name as section_name
         from guardian_student gs
         join people st on st.id = gs.student_id
         left join enrollments e on e.student_id = st.id and e.status = 'active'
         left join class_sections cs on cs.id = e.class_section_id
        where gs.guardian_id = $1
        order by st.id, cs.name`,
      [personId]
    );
    me.children = kids.rows.map((k) => ({
      id: k.id,
      full_name: k.full_name,
      ...k.section_id && k.section_name ? { class_section: { id: k.section_id, name: k.section_name } } : {}
    })).sort((a, b) => a.full_name.localeCompare(b.full_name));
  }
  if (row.role === "teacher") {
    const secs = await tx.query(
      `select cs.id, cs.name, cs.grade_level, cs.term_id, string_agg(st.subject, ', ' order by st.subject) as subject
         from section_teachers st
         join class_sections cs on cs.id = st.section_id
         join terms t on t.id = cs.term_id and not t.closed
        where st.teacher_id = $1
        group by cs.id order by cs.name`,
      [personId]
    );
    me.sections = secs.rows;
  }
  return me;
}

// src/auth/phone.ts
function normalizePhone(raw, defaultCountryCode) {
  const trimmed = raw.trim();
  const digits = trimmed.replace(/\D/g, "");
  let e164;
  if (trimmed.startsWith("+")) e164 = `+${digits}`;
  else if (digits.startsWith("00")) e164 = `+${digits.slice(2)}`;
  else if (digits.startsWith("0")) e164 = `${defaultCountryCode}${digits.slice(1)}`;
  else e164 = `${defaultCountryCode}${digits}`;
  if (!/^\+\d{8,15}$/.test(e164)) throw badRequest("Enter a valid mobile number", "invalid_phone");
  return e164;
}

// src/auth/passwords.ts
import { randomBytes, scrypt as scryptCb, timingSafeEqual } from "node:crypto";
var N = 2 ** 15;
var R = 8;
var P = 1;
var KEYLEN = 32;
function derive(password, salt, n, r, p) {
  const opts = { N: n, r, p, maxmem: 128 * n * r * 2 };
  return new Promise(
    (resolve, reject) => scryptCb(password.normalize("NFKC"), salt, KEYLEN, opts, (err, key) => err ? reject(err) : resolve(key))
  );
}
async function hashPassword(password) {
  const salt = randomBytes(16);
  const key = await derive(password, salt, N, R, P);
  return ["scrypt", N, R, P, salt.toString("base64url"), key.toString("base64url")].join("$");
}
async function verifyPassword(password, stored) {
  const [scheme, n, r, p, salt, hash] = stored.split("$");
  if (scheme !== "scrypt" || !n || !r || !p || !salt || !hash) return false;
  const expected = Buffer.from(hash, "base64url");
  const actual = await derive(password, Buffer.from(salt, "base64url"), Number(n), Number(r), Number(p));
  return actual.length === expected.length && timingSafeEqual(actual, expected);
}
var dummy;
function dummyHash() {
  dummy ??= hashPassword(randomBytes(12).toString("hex"));
  return dummy;
}

// src/auth/tokens.ts
import { createHash as createHash3, randomBytes as randomBytes2 } from "node:crypto";
import { SignJWT, jwtVerify, errors as joseErrors } from "jose";
var ISSUER = "homeroom";
var AUDIENCE = "homeroom-api";
function createTokenService(secret, now) {
  const key = new TextEncoder().encode(secret);
  const sign = (claims, sub, typ, ttl) => {
    const iat = Math.floor(now().getTime() / 1e3);
    return new SignJWT({ ...claims, typ }).setProtectedHeader({ alg: "HS256" }).setSubject(sub).setIssuer(ISSUER).setAudience(AUDIENCE).setIssuedAt(iat).setExpirationTime(iat + ttl).sign(key);
  };
  const verify = async (token, typ) => {
    try {
      const { payload } = await jwtVerify(token, key, {
        issuer: ISSUER,
        audience: AUDIENCE,
        algorithms: ["HS256"],
        currentDate: now()
      });
      if (payload["typ"] !== typ || !payload.sub) throw unauthorized("Wrong token type", "invalid_token");
      return payload;
    } catch (err) {
      if (err instanceof joseErrors.JWTExpired) throw unauthorized("Token expired", "token_expired");
      if (err instanceof Error && err.name === "AppError") throw err;
      throw unauthorized("Invalid token", "invalid_token");
    }
  };
  return {
    signAccess: (c, ttl) => sign({ role: c.role, sch: c.schoolId, sid: c.sessionId }, c.personId, "access", ttl),
    async verifyAccess(token) {
      const p = await verify(token, "access");
      return {
        personId: p.sub,
        role: p["role"],
        schoolId: p["sch"],
        sessionId: p["sid"]
      };
    },
    signSelection: (accountId, ttl) => sign({}, accountId, "select", ttl),
    async verifySelection(token) {
      const p = await verify(token, "select");
      return { accountId: p.sub };
    }
  };
}
function newRefreshToken() {
  const token = randomBytes2(32).toString("base64url");
  return { token, hash: hashToken(token) };
}
function hashToken(token) {
  return createHash3("sha256").update(token).digest("hex");
}

// src/auth/service.ts
var OTP_TTL_MS = 10 * 60 * 1e3;
var OTP_MAX_ATTEMPTS = 5;
var OTP_MAX_PER_HOUR = 5;
var SELECTION_TTL_SECONDS = 5 * 60;
var RESET_TTL_MS = 60 * 60 * 1e3;
var INVITE_TTL_MS = 7 * 24 * 60 * 60 * 1e3;
function createAuthService(deps2) {
  const { db, config: config2, clock, tokens } = deps2;
  const invalidCredentials = () => unauthorized("Incorrect email or password", "invalid_credentials");
  async function createSession(accountId, personId, familyId = randomUUID2()) {
    const refresh = newRefreshToken();
    const now = clock.now();
    const person = await db.asService(async (tx) => {
      const r = await tx.query("select role, school_id from people where id = $1", [personId]);
      const row = r.rows[0];
      if (!row) throw forbidden("This person no longer exists", "no_active_membership");
      await tx.query(
        `insert into refresh_tokens (family_id, account_id, person_id, token_hash, expires_at)
         values ($1, $2, $3, $4, $5)`,
        [familyId, accountId, personId, refresh.hash, new Date(now.getTime() + config2.REFRESH_TOKEN_TTL_SECONDS * 1e3)]
      );
      return row;
    });
    const access = await tokens.signAccess(
      { personId, role: person.role, schoolId: person.school_id, sessionId: familyId },
      config2.ACCESS_TOKEN_TTL_SECONDS
    );
    const me = await db.asUser(personId, (tx) => loadMe(tx, personId, clock.now()));
    return { access_token: access, refresh_token: refresh.token, expires_in: config2.ACCESS_TOKEN_TTL_SECONDS, me };
  }
  async function resolveAccount(accountId) {
    const people = await db.asService(
      (tx) => tx.query(
        `select p.id, p.role, p.full_name, s.name as school_name
           from people p join schools s on s.id = p.school_id
          where p.auth_user_id = $1 order by s.name, p.role`,
        [accountId]
      )
    );
    if (people.rows.length === 0) throw forbidden("This account is not linked to any school", "no_active_membership");
    if (people.rows.length === 1) return { status: "signed_in", session: await createSession(accountId, people.rows[0].id) };
    return {
      status: "selection_required",
      selection: {
        selection_token: await tokens.signSelection(accountId, SELECTION_TTL_SECONDS),
        choices: people.rows.map((p) => ({ person_id: p.id, role: p.role, school_name: p.school_name, full_name: p.full_name }))
      }
    };
  }
  const otpHash = (phone, code) => createHmac("sha256", config2.JWT_SECRET).update(`${phone}:${code}`).digest("hex");
  return {
    createSession,
    async signInWithPassword(email, password) {
      const acct = await db.asService(async (tx) => {
        const r = await tx.query(
          "select id, password_hash, disabled_at from accounts where email = $1",
          [email.trim().toLowerCase()]
        );
        return r.rows[0];
      });
      const ok = await verifyPassword(password, acct?.password_hash ?? await dummyHash());
      if (!acct || !acct.password_hash || !ok || acct.disabled_at) throw invalidCredentials();
      return resolveAccount(acct.id);
    },
    async selectPerson(selectionToken, personId) {
      const { accountId } = await tokens.verifySelection(selectionToken);
      const owns = await db.asService(
        (tx) => tx.query("select 1 from people where id = $1 and auth_user_id = $2", [personId, accountId])
      );
      if (owns.rowCount === 0) throw forbidden("That role does not belong to this account", "invalid_selection");
      return createSession(accountId, personId);
    },
    /**
     * Refresh tokens are single-use and rotate. Presenting one that was already used means it
     * leaked (or a client is buggy), so the whole family is revoked and the user signs in again.
     */
    async refresh(token) {
      const now = clock.now();
      const outcome = await db.asService(async (tx) => {
        const r = await tx.query(
          `select id, family_id, account_id, person_id, expires_at, revoked_at
             from refresh_tokens where token_hash = $1 for update`,
          [hashToken(token)]
        );
        const row = r.rows[0];
        if (!row) return { kind: "invalid" };
        if (row.revoked_at) {
          await tx.query("update refresh_tokens set revoked_at = $2 where family_id = $1 and revoked_at is null", [row.family_id, now]);
          return { kind: "reused" };
        }
        if (row.expires_at <= now) return { kind: "expired" };
        await tx.query("update refresh_tokens set revoked_at = $2 where id = $1", [row.id, now]);
        return { kind: "ok", row };
      });
      if (outcome.kind === "invalid") throw unauthorized("Invalid refresh token", "invalid_refresh_token");
      if (outcome.kind === "reused") throw unauthorized("Session revoked, please sign in again", "refresh_token_reused");
      if (outcome.kind === "expired") throw unauthorized("Session expired, please sign in again", "refresh_token_expired");
      const disabled = await db.asService((tx) => tx.query("select 1 from accounts where id = $1 and disabled_at is not null", [outcome.row.account_id]));
      if (disabled.rowCount) throw unauthorized("Account disabled", "account_disabled");
      return createSession(outcome.row.account_id, outcome.row.person_id, outcome.row.family_id);
    },
    async signOut(sessionId) {
      await db.asService(
        (tx) => tx.query("update refresh_tokens set revoked_at = $2 where family_id = $1 and revoked_at is null", [sessionId, clock.now()])
      );
    },
    /** Always succeeds from the caller's view, so it cannot reveal which emails have accounts. */
    async requestPasswordReset(email) {
      const now = clock.now();
      const found = await db.asService(async (tx) => {
        const a = await tx.query("select id from accounts where email = $1 and disabled_at is null", [email.trim().toLowerCase()]);
        const acct = a.rows[0];
        if (!acct) return null;
        const { token, hash } = newRefreshToken();
        await tx.query("insert into password_resets (account_id, token_hash, expires_at, created_at) values ($1, $2, $3, $4)", [
          acct.id,
          hash,
          new Date(now.getTime() + RESET_TTL_MS),
          now
        ]);
        return token;
      });
      if (found) {
        const link = `${config2.PUBLIC_WEB_URL}/#/reset?token=${found}`;
        await deps2.email.send(email.trim().toLowerCase(), "Reset your Homeroom password", `Use this link within one hour to choose a new password:
${link}

If you did not ask for this, ignore this message.`);
      }
    },
    /** Sets the password from a reset or invitation link, then signs the account out everywhere. */
    async resetPassword(token, newPassword) {
      const now = clock.now();
      const hash = await hashPassword(newPassword);
      const ok = await db.asService(async (tx) => {
        const r = await tx.query(
          `select id, account_id from password_resets
            where token_hash = $1 and used_at is null and expires_at > $2 for update`,
          [hashToken(token), now]
        );
        const row = r.rows[0];
        if (!row) return false;
        await tx.query("update password_resets set used_at = $2 where id = $1", [row.id, now]);
        await tx.query("update accounts set password_hash = $2 where id = $1", [row.account_id, hash]);
        await tx.query("update refresh_tokens set revoked_at = $2 where account_id = $1 and revoked_at is null", [row.account_id, now]);
        return true;
      });
      if (!ok) throw new AppError(400, "invalid_reset_token", "This link is invalid or has expired. Request a new one.");
    },
    /**
     * Give a person a login. If the email or phone already belongs to an account (for example a
     * teacher who is also a parent at the school) the person is linked to it instead, so one sign-in
     * covers both roles. Staff with an email get a set-password link; guardians with only a phone sign in by SMS code.
     */
    async inviteAccount(personId, contact) {
      const email = contact.email?.trim().toLowerCase() || null;
      const phone = contact.phone ? normalizePhone(contact.phone, config2.DEFAULT_COUNTRY_CODE) : null;
      if (!email && !phone) return;
      const now = clock.now();
      const outcome = await db.asService(async (tx) => {
        const existing = await tx.query(
          "select id from accounts where ($1::text is not null and email = $1) or ($2::text is not null and phone = $2) limit 1",
          [email, phone]
        );
        let accountId = existing.rows[0]?.id;
        let isNew = false;
        if (!accountId) {
          const a = await tx.query("insert into accounts (email, phone) values ($1, $2) returning id", [email, phone]);
          accountId = a.rows[0].id;
          isNew = true;
        }
        await tx.query("update people set auth_user_id = $1 where id = $2", [accountId, personId]);
        if (!isNew || !email) return { isNew, token: null };
        const { token, hash } = newRefreshToken();
        await tx.query("insert into password_resets (account_id, token_hash, expires_at, created_at) values ($1, $2, $3, $4)", [
          accountId,
          hash,
          new Date(now.getTime() + INVITE_TTL_MS),
          now
        ]);
        return { isNew, token };
      });
      if (outcome.token && email) {
        await deps2.email.send(email, "Welcome to Homeroom", `Your school has created a Homeroom account for you. Choose a password within 7 days:
${config2.PUBLIC_WEB_URL}/#/reset?token=${outcome.token}`);
      } else if (outcome.isNew && phone) {
        await deps2.sms.send(phone, `Your school has added you to Homeroom. Open ${config2.PUBLIC_WEB_URL} and sign in with your mobile number: we will text you a code.`);
      }
    },
    /** Always succeeds from the caller's view, so it cannot be used to discover which numbers have accounts. */
    async requestOtp(rawPhone) {
      const phone = normalizePhone(rawPhone, config2.DEFAULT_COUNTRY_CODE);
      const now = clock.now();
      const code = randomInt(0, 1e6).toString().padStart(6, "0");
      const send = await db.asService(async (tx) => {
        const recent = await tx.query(
          "select count(*)::int as n from otp_codes where phone = $1 and created_at > $2",
          [phone, new Date(now.getTime() - 36e5)]
        );
        if ((recent.rows[0]?.n ?? 0) >= OTP_MAX_PER_HOUR) throw tooMany("Too many codes requested. Try again later.");
        const acct = await tx.query("select 1 from accounts where phone = $1 and disabled_at is null", [phone]);
        await tx.query("insert into otp_codes (phone, code_hash, expires_at, created_at) values ($1, $2, $3, $4)", [
          phone,
          otpHash(phone, code),
          new Date(now.getTime() + OTP_TTL_MS),
          now
        ]);
        return acct.rowCount > 0;
      });
      if (send) await deps2.sms.send(phone, `Your Homeroom code is ${code}. It expires in 10 minutes.`);
    },
    async verifyOtp(rawPhone, code) {
      const phone = normalizePhone(rawPhone, config2.DEFAULT_COUNTRY_CODE);
      const now = clock.now();
      const accountId = await db.asService(async (tx) => {
        const r = await tx.query(
          `select id, code_hash, attempts from otp_codes
            where phone = $1 and consumed_at is null and expires_at > $2
            order by created_at desc limit 1 for update`,
          [phone, now]
        );
        const row = r.rows[0];
        if (!row || row.attempts >= OTP_MAX_ATTEMPTS) return null;
        const good = safeEq(row.code_hash, otpHash(phone, code));
        await tx.query("update otp_codes set attempts = attempts + 1, consumed_at = $2 where id = $1", [row.id, good ? now : null]);
        if (!good) return null;
        const a = await tx.query("select id from accounts where phone = $1 and disabled_at is null", [phone]);
        return a.rows[0]?.id ?? null;
      });
      if (!accountId) throw new AppError(401, "invalid_code", "That code is wrong or has expired");
      return resolveAccount(accountId);
    }
  };
}
function safeEq(a, b) {
  const x = Buffer.from(a);
  const y = Buffer.from(b);
  return x.length === y.length && timingSafeEqual2(x, y);
}

// src/http/helpers.ts
import { z } from "zod";
var uuid = z.string().regex(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i, "expected a UUID");
var isoDate = z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "expected YYYY-MM-DD");
async function body(c, schema2) {
  let raw;
  try {
    raw = await c.req.json();
  } catch {
    throw badRequest("Request body must be valid JSON", "invalid_json");
  }
  return schema2.parse(raw);
}
function query(c, schema2) {
  return schema2.parse(c.req.query());
}
function idParam(c, name = "id") {
  const parsed = uuid.safeParse(c.req.param(name));
  if (!parsed.success) throw notFound();
  return parsed.data;
}
function asCaller(deps2, c, fn) {
  return deps2.db.asUser(c.var.auth.personId, (tx) => fn(tx, c.var.auth));
}
var encodeCursor = (cur) => Buffer.from(JSON.stringify(cur)).toString("base64url");
function decodeCursor(token) {
  if (!token) return void 0;
  try {
    const v = JSON.parse(Buffer.from(token, "base64url").toString("utf8"));
    if (typeof v.t === "string" && uuid.safeParse(v.id).success) return v;
  } catch {
  }
  throw badRequest("Invalid cursor", "invalid_cursor");
}
var pageQuery = z.object({
  limit: z.coerce.number().int().min(1).max(200).default(50),
  cursor: z.string().optional()
});
function paginate(rows, limit, sortKey) {
  const items = rows.slice(0, limit);
  const last = items[items.length - 1];
  return {
    items,
    next_cursor: rows.length > limit && last ? encodeCursor({ t: sortKey(last), id: last.id }) : null
  };
}
var iso = (d) => d == null ? null : d instanceof Date ? d.toISOString() : new Date(d).toISOString();
var money = (n) => Number(n ?? 0).toFixed(2);

// src/modules/auth/routes.ts
function authRoutes(deps2) {
  const r = new Hono();
  const auth = createAuthService(deps2);
  const limited = (bucket) => rateLimit({ bucket, limit: deps2.config.AUTH_RATE_LIMIT_PER_MINUTE, windowMs: 6e4, now: deps2.clock.now });
  r.post("/sessions", limited("signin"), async (c) => {
    const { email, password } = await body(c, z2.object({ email: z2.email(), password: z2.string().min(1).max(200) }));
    return c.json(await auth.signInWithPassword(email, password));
  });
  r.post("/sessions/select", limited("select"), async (c) => {
    const b = await body(c, z2.object({ selection_token: z2.string().min(1), person_id: uuid }));
    return c.json(await auth.selectPerson(b.selection_token, b.person_id));
  });
  r.delete("/sessions/current", authenticate(deps2), async (c) => {
    await auth.signOut(c.var.auth.sessionId);
    return c.body(null, 204);
  });
  r.post("/refresh", limited("refresh"), async (c) => {
    const { refresh_token } = await body(c, z2.object({ refresh_token: z2.string().min(1) }));
    return c.json(await auth.refresh(refresh_token));
  });
  r.post("/otp", limited("otp"), async (c) => {
    const { phone } = await body(c, z2.object({ phone: z2.string().min(6).max(25) }));
    await auth.requestOtp(phone);
    return c.body(null, 204);
  });
  r.post("/otp/verify", limited("otp-verify"), async (c) => {
    const { phone, code } = await body(c, z2.object({ phone: z2.string().min(6).max(25), code: z2.string().regex(/^\d{6}$/) }));
    return c.json(await auth.verifyOtp(phone, code));
  });
  r.post("/password/forgot", limited("pw-forgot"), async (c) => {
    const { email } = await body(c, z2.object({ email: z2.email() }));
    await auth.requestPasswordReset(email);
    return c.body(null, 204);
  });
  r.post("/password/reset", limited("pw-reset"), async (c) => {
    const b = await body(c, z2.object({ token: z2.string().min(10).max(200), new_password: z2.string().min(8).max(200) }));
    await auth.resetPassword(b.token, b.new_password);
    return c.body(null, 204);
  });
  return r;
}

// src/modules/admin/routes.ts
import { Hono as Hono2 } from "hono";
import { z as z3 } from "zod";
var toPerson = (p) => ({
  id: p.id,
  full_name: p.full_name,
  role: p.role,
  ...p.phone || p.email ? { contact: { ...p.phone ? { phone: p.phone } : {}, ...p.email ? { email: p.email } : {} } } : {}
});
var PERSON_SELECT = `select p.id, p.full_name, p.role, c.phone, c.email from people p left join person_contacts c on c.person_id = p.id`;
var encodeAuditCursor = (id) => Buffer.from(String(id)).toString("base64url");
function decodeAuditCursor(token) {
  if (!token) return void 0;
  const n = Number(Buffer.from(token, "base64url").toString("utf8"));
  if (!Number.isInteger(n) || n <= 0) throw badRequest("Invalid cursor", "invalid_cursor");
  return n;
}
function adminRoutes(deps2) {
  const r = new Hono2();
  const admin = requireRole("admin");
  const auth = createAuthService(deps2);
  r.get("/people", admin, async (c) => {
    const q = query(c, pageQuery.extend({ role: z3.enum(["admin", "teacher", "guardian"]).optional(), q: z3.string().max(100).optional() }));
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const params = [q.limit + 1, q.role ?? null, q.q ?? null];
        let cursorSql = "";
        if (cur) {
          params.push(cur.t, cur.id);
          cursorSql = `and (p.full_name, p.id) > ($4, $5::uuid)`;
        }
        const rows = await tx.query(
          `${PERSON_SELECT}
            where p.role <> 'student' and ($2::person_role is null or p.role = $2::person_role)
              and ($3::text is null or strpos(lower(p.full_name), lower($3)) > 0) ${cursorSql}
            order by p.full_name, p.id limit $1`,
          params
        );
        const page = paginate(rows.rows, q.limit, (p) => p.full_name);
        const teacherIds = page.items.filter((p) => p.role === "teacher").map((p) => p.id);
        const assignments = /* @__PURE__ */ new Map();
        if (teacherIds.length) {
          const a = await tx.query(
            `select st.teacher_id, cs.id as section_id, cs.name as section_name, st.subject
               from section_teachers st join class_sections cs on cs.id = st.section_id
               join terms t on t.id = cs.term_id and not t.closed
              where st.teacher_id = any($1::uuid[]) order by cs.name, st.subject`,
            [teacherIds]
          );
          for (const x of a.rows) {
            const list = assignments.get(x.teacher_id) ?? [];
            list.push({ class_section: { id: x.section_id, name: x.section_name }, subject: x.subject });
            assignments.set(x.teacher_id, list);
          }
        }
        return {
          items: page.items.map((p) => ({ ...toPerson(p), ...assignments.has(p.id) ? { assignments: assignments.get(p.id) } : {} })),
          next_cursor: page.next_cursor
        };
      })
    );
  });
  r.post("/people", admin, async (c) => {
    const b = await body(
      c,
      z3.object({
        full_name: z3.string().trim().min(1).max(120),
        role: z3.enum(["admin", "teacher", "guardian", "student"]),
        email: z3.email().optional(),
        phone: z3.string().min(6).max(25).optional(),
        invite: z3.boolean().default(false)
      })
    );
    const phone = b.phone ? normalizePhone(b.phone, deps2.config.DEFAULT_COUNTRY_CODE) : null;
    const email = b.email ? b.email.toLowerCase() : null;
    const person = await asCaller(deps2, c, async (tx, me) => {
      const p = await tx.query(
        "insert into people (school_id, full_name, role) values ($1, $2, $3) returning id",
        [me.schoolId, b.full_name, b.role]
      );
      const id = p.rows[0].id;
      if (phone || email) {
        await tx.query("insert into person_contacts (person_id, school_id, phone, email) values ($1, $2, $3, $4)", [id, me.schoolId, phone, email]);
      }
      return toPerson({ id, full_name: b.full_name, role: b.role, phone, email });
    });
    if (b.invite && b.role !== "student") await auth.inviteAccount(person.id, { email, phone });
    return c.json(person, 201);
  });
  r.put("/students/:id/guardians", admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, z3.object({ guardian_id: uuid, relationship: z3.string().max(40).optional(), is_primary_contact: z3.boolean().optional() }));
    await asCaller(deps2, c, async (tx, me) => {
      const s = await tx.query(`select 1 from people where id = $1 and role = 'student'`, [id]);
      if (s.rowCount === 0) throw notFound("Student");
      await tx.query(
        `insert into guardian_student (school_id, guardian_id, student_id, relationship, is_primary_contact)
         values ($1, $2, $3, coalesce($4, 'guardian'), coalesce($5, false))
         on conflict (guardian_id, student_id) do update
           set relationship = coalesce($4, guardian_student.relationship),
               is_primary_contact = coalesce($5, guardian_student.is_primary_contact)`,
        [me.schoolId, b.guardian_id, id, b.relationship ?? null, b.is_primary_contact ?? null]
      );
    });
    return c.body(null, 204);
  });
  r.get("/audit_log", admin, async (c) => {
    const q = query(c, pageQuery.extend({ student_id: uuid.optional(), actor_id: uuid.optional(), from: isoDate.optional() }));
    const cur = decodeAuditCursor(q.cursor);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const rows = await tx.query(
          `select l.id, l.action, l.table_name, l.student_id, s.full_name as student_name, l.at,
                  a.id as actor_id, a.full_name as actor_name, a.role as actor_role
             from audit_log l join people a on a.id = l.actor_id left join people s on s.id = l.student_id
            where ($1::uuid is null or l.student_id = $1) and ($2::uuid is null or l.actor_id = $2)
              and ($3::date is null or l.at >= $3::date) and ($4::bigint is null or l.id < $4)
            order by l.id desc limit $5`,
          [q.student_id ?? null, q.actor_id ?? null, q.from ?? null, cur ?? null, q.limit + 1]
        );
        const items = rows.rows.slice(0, q.limit);
        const last = items[items.length - 1];
        return {
          items: items.map((l) => ({
            id: Number(l.id),
            actor: { id: l.actor_id, full_name: l.actor_name, role: l.actor_role },
            action: l.action,
            table_name: l.table_name,
            student_id: l.student_id,
            ...l.student_id && l.student_name ? { student: { id: l.student_id, full_name: l.student_name } } : {},
            at: l.at.toISOString()
          })),
          next_cursor: rows.rows.length > q.limit && last ? encodeAuditCursor(Number(last.id)) : null
        };
      })
    );
  });
  return r;
}

// src/modules/announcements/routes.ts
import { Hono as Hono3 } from "hono";
import { z as z4 } from "zod";

// src/modules/shared.ts
var personRef = (r) => ({
  id: r.id,
  full_name: r.full_name,
  role: r.role
});
var studentRef = (r) => ({
  id: r.id,
  full_name: r.full_name,
  ...r.section_id && r.section_name ? { class_section: { id: r.section_id, name: r.section_name } } : {}
});
function todayIn(timeZone, now) {
  return new Intl.DateTimeFormat("en-CA", { timeZone, year: "numeric", month: "2-digit", day: "2-digit" }).format(now);
}
async function schoolTimezone(tx) {
  const r = await tx.query("select timezone from schools where id = app.school_id()");
  return r.rows[0]?.timezone ?? "UTC";
}
async function visibleStudent(tx, studentId, auditAs) {
  const r = await tx.query(
    `select id, full_name from people where id = $1 and role = 'student'`,
    [studentId]
  );
  const row = r.rows[0];
  if (!row) throw notFound("Student");
  await tx.query("select app.log_read($1, $2)", [studentId, auditAs]);
  return row;
}
var round1 = (n) => Math.round(n * 10) / 10;
function runningGrade(items) {
  let got = 0;
  let weights = 0;
  for (const i of items) {
    if (i.score == null) continue;
    got += i.score / i.max_score * i.weight;
    weights += i.weight;
  }
  return weights === 0 ? null : round1(100 * got / weights);
}
function gradeBandFor(score, bands) {
  if (score == null) return null;
  let best = null;
  for (const b of bands) {
    if (score >= b.min_score && score <= b.max_score && (!best || b.min_score > best.min_score)) best = b;
  }
  return best?.label ?? null;
}
var num = (v) => v == null ? null : Number(v);
var hhmm = (t) => t.slice(0, 5);

// src/modules/announcements/routes.ts
var toResponse = (x) => ({
  announcement_id: x.announcement_id,
  student_id: x.student_id,
  guardian_id: x.guardian_id,
  response: x.response,
  responded_at: x.responded_at.toISOString()
});
var ANN_SELECT = `
  select a.id, a.class_section_id, a.title, a.body, a.requires_response, a.published_at, a.created_at,
         au.id as author_id, au.full_name as author_name, au.role as author_role
    from announcements a left join people au on au.id = a.author_id`;
async function mapAnnouncements(tx, rows, withMine) {
  const mine = /* @__PURE__ */ new Map();
  if (withMine && rows.length) {
    const rs = await tx.query(
      "select announcement_id, student_id, guardian_id, response, responded_at from announcement_responses where announcement_id = any($1::uuid[])",
      [rows.map((r) => r.id)]
    );
    for (const x of rs.rows) mine.set(x.announcement_id, [...mine.get(x.announcement_id) ?? [], toResponse(x)]);
  }
  return rows.map((a) => ({
    id: a.id,
    // Authors the caller cannot see (an administrator, to a parent) are simply omitted.
    ...a.author_id && a.author_name && a.author_role ? { author: personRef({ id: a.author_id, full_name: a.author_name, role: a.author_role }) } : {},
    class_section_id: a.class_section_id,
    title: a.title,
    body: a.body,
    requires_response: a.requires_response,
    published_at: iso(a.published_at),
    ...withMine && a.requires_response ? { my_responses: mine.get(a.id) ?? [] } : {}
  }));
}
function announcementRoutes(deps2) {
  const r = new Hono3();
  r.get("/announcements", async (c) => {
    const q = query(c, pageQuery);
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps2, c, async (tx, me) => {
        const params = [q.limit + 1];
        let cursorSql = "";
        if (cur) {
          params.push(cur.t, cur.id);
          cursorSql = `where (coalesce(a.published_at, a.created_at), a.id) < ($2::timestamptz, $3::uuid)`;
        }
        const rows = await tx.query(
          `${ANN_SELECT} ${cursorSql} order by coalesce(a.published_at, a.created_at) desc, a.id desc limit $1`,
          params
        );
        const page = paginate(rows.rows, q.limit, (a) => (a.published_at ?? a.created_at).toISOString());
        return { items: await mapAnnouncements(tx, page.items, me.role === "guardian"), next_cursor: page.next_cursor };
      })
    );
  });
  r.post("/announcements", requireRole("admin", "teacher"), async (c) => {
    const b = await body(
      c,
      z4.object({
        title: z4.string().trim().min(1).max(200),
        body: z4.string().trim().min(1).max(1e4),
        class_section_id: uuid.nullable().optional(),
        requires_response: z4.boolean().default(false),
        published: z4.boolean().default(false)
      })
    );
    const out = await asCaller(deps2, c, async (tx, me) => {
      const now = deps2.clock.now();
      try {
        const ins = await tx.attempt(
          () => tx.query(
            `insert into announcements (school_id, author_id, class_section_id, title, body, requires_response, published_at, created_at)
             values (app.school_id(), $1, $2, $3, $4, $5, $6, $7) returning id`,
            [me.personId, b.class_section_id ?? null, b.title, b.body, b.requires_response, b.published ? now : null, now]
          )
        );
        const rows = await tx.query(`${ANN_SELECT} where a.id = $1`, [ins.rows[0].id]);
        return (await mapAnnouncements(tx, rows.rows, false))[0];
      } catch (err) {
        if (err.code === "42501")
          throw forbidden(me.role === "teacher" ? "Teachers can only post to a class they teach" : "You cannot post this announcement", "cannot_post_here");
        throw err;
      }
    });
    return c.json(out, 201);
  });
  r.post("/announcements/:id/publish", requireRole("admin", "teacher"), async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const cur = await tx.query("select published_at from announcements where id = $1", [id]);
        if (!cur.rows[0]) throw notFound("Announcement");
        if (!cur.rows[0].published_at) {
          const u = await tx.query("update announcements set published_at = $2 where id = $1", [id, deps2.clock.now()]);
          if (u.rowCount === 0) throw forbidden("Only the author or an administrator can publish this", "not_author");
        }
        const rows = await tx.query(`${ANN_SELECT} where a.id = $1`, [id]);
        return (await mapAnnouncements(tx, rows.rows, false))[0];
      })
    );
  });
  r.get("/announcements/:id/responses", requireRole("admin"), async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const a = await tx.query(
          "select class_section_id, requires_response from announcements where id = $1",
          [id]
        );
        if (!a.rows[0]) throw notFound("Announcement");
        const rs = await tx.query(
          "select announcement_id, student_id, guardian_id, response, responded_at from announcement_responses where announcement_id = $1 order by responded_at",
          [id]
        );
        const audience = await tx.query(
          `select count(distinct e.student_id)::int as n from enrollments e
             join class_sections cs on cs.id = e.class_section_id join terms t on t.id = cs.term_id and not t.closed
            where e.status = 'active' and ($1::uuid is null or e.class_section_id = $1)`,
          [a.rows[0].class_section_id]
        );
        const yes = rs.rows.filter((x) => x.response === "yes").length;
        const no = rs.rows.length - yes;
        return { yes, no, awaiting: Math.max(0, (audience.rows[0]?.n ?? 0) - rs.rows.length), items: rs.rows.map(toResponse) };
      })
    );
  });
  r.put("/announcements/:id/responses", requireRole("guardian"), async (c) => {
    const id = idParam(c);
    const b = await body(c, z4.object({ student_id: uuid, response: z4.enum(["yes", "no"]) }));
    return c.json(
      await asCaller(deps2, c, async (tx, me) => {
        const a = await tx.query("select requires_response from announcements where id = $1", [id]);
        if (!a.rows[0]) throw notFound("Announcement");
        if (!a.rows[0].requires_response) throw forbidden("This announcement does not ask for a reply", "no_response_expected");
        try {
          const u = await tx.attempt(
            () => tx.query(
              `insert into announcement_responses (school_id, announcement_id, student_id, guardian_id, response, responded_at)
               values (app.school_id(), $1, $2, $3, $4, $5)
               on conflict (announcement_id, student_id) do update
                 set response = excluded.response, guardian_id = excluded.guardian_id, responded_at = excluded.responded_at
               returning announcement_id, student_id, guardian_id, response, responded_at`,
              [id, b.student_id, me.personId, b.response, deps2.clock.now()]
            )
          );
          return toResponse(u.rows[0]);
        } catch (err) {
          if (err.code === "42501") throw forbidden("You can only reply for your own child", "not_your_child");
          throw err;
        }
      })
    );
  });
  return r;
}

// src/modules/attendance/routes.ts
import { Hono as Hono4 } from "hono";
import { z as z5 } from "zod";
var status = z5.enum(["present", "late", "absent", "excused"]);
var MAX_ENTRIES = 200;
var CLOCK_SKEW_MS = 5 * 60 * 1e3;
var submission = z5.object({
  date: isoDate,
  period_id: uuid.nullable().optional(),
  entries: z5.array(z5.object({ student_id: uuid, status, note: z5.string().max(500).optional(), marked_at: z5.iso.datetime() })).min(1).max(MAX_ENTRIES)
});
async function visibleSection(tx, id) {
  const r = await tx.query(
    `select cs.id, cs.name, t.closed as term_closed from class_sections cs join terms t on t.id = cs.term_id where cs.id = $1`,
    [id]
  );
  if (!r.rows[0]) throw notFound("Class section");
  return r.rows[0];
}
var csvCell = (v) => {
  const s = v == null ? "" : String(v);
  const safe = /^[=+\-@\t\r]/.test(s) ? `'${s}` : s;
  return /[",\n\r]/.test(safe) ? `"${safe.replace(/"/g, '""')}"` : safe;
};
function attendanceRoutes(deps2) {
  const r = new Hono4();
  r.get("/class_sections/:id/attendance", requireRole("teacher", "admin"), async (c) => {
    const id = idParam(c);
    const q = query(c, z5.object({ date: isoDate, period_id: uuid.optional() }));
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const section = await visibleSection(tx, id);
        const rows = await tx.query(
          `select p.id, p.full_name, a.status, a.note, a.id as record_id
             from enrollments e
             join people p on p.id = e.student_id
             left join attendance_records a
               on a.student_id = p.id and a.class_section_id = e.class_section_id
              and a.period_date = $2 and a.period_id is not distinct from $3::uuid
            where e.class_section_id = $1 and e.status = 'active'
            order by p.full_name`,
          [id, q.date, q.period_id ?? null]
        );
        return {
          class_section_id: id,
          period_id: q.period_id ?? null,
          date: q.date,
          term_closed: section.term_closed,
          entries: rows.rows.map((x) => ({
            student: studentRef({ id: x.id, full_name: x.full_name }),
            status: x.status,
            note: x.note,
            record_id: x.record_id
          }))
        };
      })
    );
  });
  r.put("/class_sections/:id/attendance", requireRole("teacher", "admin"), async (c) => {
    const id = idParam(c);
    const b = await body(c, submission);
    const now = deps2.clock.now();
    return c.json(
      await asCaller(deps2, c, async (tx, me) => {
        const section = await visibleSection(tx, id);
        if (section.term_closed && me.role !== "admin") {
          throw new AppError(403, "term_closed", "This term is closed; only an administrator can change its attendance");
        }
        const results = [];
        let applied = 0;
        let rejected = 0;
        for (const e of b.entries) {
          const markedAt = new Date(Math.min(new Date(e.marked_at).getTime(), now.getTime() + CLOCK_SKEW_MS));
          try {
            const out = await tx.attempt(
              () => tx.query(
                `insert into attendance_records
                   (school_id, student_id, class_section_id, period_id, period_date, status, marked_by, note, marked_at)
                 values (app.school_id(), $1, $2, $3, $4, $5, app.person_id(), $6, $7)
                 on conflict (student_id, class_section_id, period_id, period_date) do update
                   set status = excluded.status, note = excluded.note,
                       marked_by = excluded.marked_by, marked_at = excluded.marked_at
                   where attendance_records.marked_at <= excluded.marked_at
                 returning id`,
                [e.student_id, id, b.period_id ?? null, b.date, e.status, e.note ?? null, markedAt]
              )
            );
            if (out.rowCount > 0) {
              applied++;
              results.push({ student_id: e.student_id, outcome: "applied" });
            } else {
              results.push({ student_id: e.student_id, outcome: "stale", message: "A newer mark already exists" });
            }
          } catch (err) {
            const code = err.code;
            rejected++;
            results.push({
              student_id: e.student_id,
              outcome: "rejected",
              code: code === "42501" ? "not_enrolled" : code === "23503" ? "unknown_student" : code === "23514" ? "invalid_student" : "error",
              message: code === "42501" ? "This student is not enrolled in the section" : code === "23503" ? "No such student or period" : code === "23514" ? "Not a student" : "Could not be saved"
            });
            if (!["42501", "23503", "23514"].includes(code ?? "")) throw err;
          }
        }
        return { applied, rejected, results };
      })
    );
  });
  r.patch("/attendance_records/:id", async (c) => {
    const id = idParam(c);
    const b = await body(c, z5.object({ status: status.optional(), note: z5.string().max(500).nullable().optional() }));
    return c.json(
      await asCaller(deps2, c, async (tx, me) => {
        const cur = await tx.query("select 1 from attendance_records where id = $1", [id]);
        if (cur.rowCount === 0) throw notFound("Attendance record");
        const u = await tx.query(
          `update attendance_records
              set status = coalesce($2::attendance_status, status),
                  note = case when $4 then $3 else note end,
                  marked_by = $5, marked_at = $6
            where id = $1
        returning id, student_id, class_section_id, period_id, period_date, status, note, marked_by, marked_at`,
          [id, b.status ?? null, b.note ?? null, "note" in b, me.personId, deps2.clock.now()]
        );
        if (!u.rows[0]) throw forbidden("This term is closed; only an administrator can change it", "term_closed");
        const row = u.rows[0];
        return { ...row, marked_at: row.marked_at.toISOString() };
      })
    );
  });
  const reportQuery = z5.object({ from: isoDate, to: isoDate, class_section_id: uuid.optional() });
  const loadReport = (c) => {
    const id = idParam(c);
    const q = query(c, reportQuery);
    return asCaller(deps2, c, async (tx, me) => {
      if (id !== me.schoolId) throw notFound("School");
      const rows = await tx.query(
        `select p.id, p.full_name, cs.id as section_id, cs.name as section_name,
                count(*) filter (where a.status = 'present')::int as present,
                count(*) filter (where a.status = 'late')::int as late,
                count(*) filter (where a.status = 'absent')::int as absent,
                count(*) filter (where a.status = 'excused')::int as excused
           from attendance_records a
           join people p on p.id = a.student_id
           join class_sections cs on cs.id = a.class_section_id
          where a.period_date between $1 and $2 and ($3::uuid is null or a.class_section_id = $3)
          group by p.id, p.full_name, cs.id, cs.name
          order by cs.name, p.full_name`,
        [q.from, q.to, q.class_section_id ?? null]
      );
      return {
        from: q.from,
        to: q.to,
        rows: rows.rows.map((x) => {
          const total = x.present + x.late + x.absent + x.excused;
          return {
            student: studentRef(x),
            present: x.present,
            late: x.late,
            absent: x.absent,
            excused: x.excused,
            rate_pct: total === 0 ? null : Math.round(1e3 * (x.present + x.late) / total) / 10
          };
        })
      };
    });
  };
  r.get("/schools/:id/attendance_report", requireRole("admin"), async (c) => c.json(await loadReport(c)));
  r.get("/schools/:id/attendance_report.csv", requireRole("admin"), async (c) => {
    const report = await loadReport(c);
    const lines = [["Student", "Section", "Present", "Late", "Absent", "Excused", "Rate %"]].concat(
      report.rows.map((x) => [
        x.student.full_name,
        x.student.class_section?.name ?? "",
        String(x.present),
        String(x.late),
        String(x.absent),
        String(x.excused),
        x.rate_pct == null ? "" : String(x.rate_pct)
      ])
    );
    return c.body(lines.map((l) => l.map(csvCell).join(",")).join("\r\n") + "\r\n", 200, {
      "content-type": "text/csv; charset=utf-8",
      "content-disposition": `attachment; filename="attendance_${report.from}_${report.to}.csv"`
    });
  });
  r.get("/teacher/today", requireRole("teacher"), async (c) => {
    const q = query(c, z5.object({ date: isoDate.optional() }));
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const date = q.date ?? todayIn(await schoolTimezone(tx), deps2.clock.now());
        const rows = await tx.query(
          `select p.id as pid, p.subject, p.weekday, p.starts_at, p.ends_at, t.id as tid, t.full_name as tname,
                  cs.id as sid, cs.name as sname, cs.grade_level, cs.term_id,
                  (select count(*)::int from enrollments e where e.class_section_id = cs.id and e.status = 'active') as enrolled,
                  (select count(*)::int from attendance_records a
                    where a.class_section_id = cs.id and a.period_id = p.id and a.period_date = $1::date) as marked
             from periods p
             join class_sections cs on cs.id = p.class_section_id
             join terms tm on tm.id = cs.term_id and $1::date between tm.starts_on and tm.ends_on
             join people t on t.id = p.teacher_id
            where p.teacher_id = app.person_id() and p.weekday = extract(isodow from $1::date)::int
            order by p.starts_at`,
          [date]
        );
        const periods = rows.rows.map((x) => ({
          period: {
            id: x.pid,
            subject: x.subject,
            weekday: x.weekday,
            starts_at: hhmm(x.starts_at),
            ends_at: hhmm(x.ends_at),
            teacher: { id: x.tid, full_name: x.tname, role: "teacher" }
          },
          class_section: { id: x.sid, name: x.sname, grade_level: x.grade_level, term_id: x.term_id },
          register: x.marked === 0 ? "unmarked" : x.marked < x.enrolled ? "partial" : "complete",
          marked: x.marked,
          enrolled: x.enrolled
        }));
        return { date, periods };
      })
    );
  });
  r.get(
    "/admin/overview",
    requireRole("admin"),
    async (c) => c.json(
      await asCaller(deps2, c, async (tx) => {
        const today = todayIn(await schoolTimezone(tx), deps2.clock.now());
        const rate = await tx.query(
          `select round(100.0 * count(*) filter (where status in ('present', 'late')) / nullif(count(*), 0), 1) as rate
             from attendance_records where period_date = $1::date`,
          [today]
        );
        const unmarked = await tx.query(
          `select p.id as pid, p.subject, p.weekday, p.starts_at, p.ends_at, t.id as tid, t.full_name as tname,
                  cs.id as sid, cs.name as sname, cs.grade_level, cs.term_id
             from periods p
             join class_sections cs on cs.id = p.class_section_id
             join terms tm on tm.id = cs.term_id and $1::date between tm.starts_on and tm.ends_on
             join people t on t.id = p.teacher_id
            where p.weekday = extract(isodow from $1::date)::int
              and not exists (select 1 from attendance_records a where a.period_id = p.id and a.period_date = $1::date)
            order by p.starts_at, cs.name`,
          [today]
        );
        const fees = await tx.query(
          `with bal as (
             select i.id, i.due_date, i.amount_due - coalesce(
                      (select sum(p.amount) from payments p where p.invoice_id = i.id and p.status = 'succeeded'), 0) as owed
               from invoices i where i.status <> 'void')
           select coalesce(sum(owed) filter (where owed > 0), 0) as outstanding,
                  count(*) filter (where owed > 0 and due_date < $1::date)::int as overdue from bal`,
          [today]
        );
        const ann = await tx.query(
          `select id, title, body, class_section_id, requires_response, published_at from announcements
            where published_at is not null order by published_at desc, id limit 5`
        );
        return {
          date: today,
          attendance_rate_today_pct: num(rate.rows[0]?.rate),
          registers_unmarked: unmarked.rows.map((x) => ({
            class_section: { id: x.sid, name: x.sname, grade_level: x.grade_level, term_id: x.term_id },
            period: {
              id: x.pid,
              subject: x.subject,
              weekday: x.weekday,
              starts_at: hhmm(x.starts_at),
              ends_at: hhmm(x.ends_at),
              teacher: { id: x.tid, full_name: x.tname, role: "teacher" }
            },
            teacher: { id: x.tid, full_name: x.tname, role: "teacher" }
          })),
          fees_outstanding: Number(fees.rows[0]?.outstanding ?? 0).toFixed(2),
          invoices_overdue: fees.rows[0]?.overdue ?? 0,
          recent_announcements: ann.rows.map((a) => ({
            id: a.id,
            title: a.title,
            body: a.body,
            class_section_id: a.class_section_id,
            requires_response: a.requires_response,
            published_at: iso(a.published_at)
          }))
        };
      })
    )
  );
  return r;
}

// src/modules/classes/routes.ts
import { Hono as Hono5 } from "hono";
import { z as z6 } from "zod";
var termInput = z6.object({
  name: z6.string().min(1).max(80),
  starts_on: isoDate,
  ends_on: isoDate,
  closed: z6.boolean()
});
var sectionInput = z6.object({
  name: z6.string().min(1).max(40),
  grade_level: z6.string().min(1).max(20),
  term_id: uuid,
  homeroom_teacher_id: uuid.nullable()
});
var periodInput = z6.object({
  subject: z6.string().min(1).max(60),
  teacher_id: uuid,
  weekday: z6.number().int().min(1).max(7),
  starts_at: z6.string().regex(/^\d{2}:\d{2}$/),
  ends_at: z6.string().regex(/^\d{2}:\d{2}$/)
});
var SECTION_SELECT = `
  select cs.id, cs.name, cs.grade_level, cs.term_id, h.id as homeroom_id, h.full_name as homeroom_name,
         (select string_agg(st.subject, ', ' order by st.subject) from section_teachers st
           where st.section_id = cs.id and st.teacher_id = app.person_id()) as subject
    from class_sections cs left join people h on h.id = cs.homeroom_teacher_id`;
var toSection = (s) => ({
  id: s.id,
  name: s.name,
  grade_level: s.grade_level,
  term_id: s.term_id,
  ...s.homeroom_id && s.homeroom_name ? { homeroom_teacher: personRef({ id: s.homeroom_id, full_name: s.homeroom_name, role: "teacher" }) } : {},
  ...s.subject ? { subject: s.subject } : {}
});
async function sectionById(tx, id) {
  const r = await tx.query(`${SECTION_SELECT} where cs.id = $1`, [id]);
  if (!r.rows[0]) throw notFound("Class section");
  return toSection(r.rows[0]);
}
function classRoutes(deps2) {
  const r = new Hono5();
  const admin = requireRole("admin");
  r.get(
    "/terms",
    async (c) => c.json({
      items: await asCaller(deps2, c, async (tx) => {
        const t = await tx.query("select id, name, starts_on, ends_on, closed from terms order by starts_on desc");
        return t.rows;
      })
    })
  );
  r.post("/terms", admin, async (c) => {
    const b = await body(c, termInput.partial({ closed: true }));
    const out = await asCaller(deps2, c, async (tx, me) => {
      const t = await tx.query(
        `insert into terms (school_id, name, starts_on, ends_on, closed) values ($1, $2, $3, $4, $5)
         returning id, name, starts_on, ends_on, closed`,
        [me.schoolId, b.name, b.starts_on, b.ends_on, b.closed ?? false]
      );
      return t.rows[0];
    });
    return c.json(out, 201);
  });
  r.patch("/terms/:id", admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, termInput.partial());
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const t = await tx.query(
          `update terms set name = coalesce($2, name), starts_on = coalesce($3::date, starts_on),
                            ends_on = coalesce($4::date, ends_on), closed = coalesce($5, closed)
            where id = $1 returning id, name, starts_on, ends_on, closed`,
          [id, b.name ?? null, b.starts_on ?? null, b.ends_on ?? null, b.closed ?? null]
        );
        if (!t.rows[0]) throw notFound("Term");
        return t.rows[0];
      })
    );
  });
  r.get("/class_sections", async (c) => {
    const q = query(c, z6.object({ term_id: uuid.optional() }));
    return c.json({
      items: await asCaller(deps2, c, async (tx) => {
        const rows = await tx.query(
          `${SECTION_SELECT} where ($1::uuid is null or cs.term_id = $1) order by cs.grade_level, cs.name`,
          [q.term_id ?? null]
        );
        return rows.rows.map(toSection);
      })
    });
  });
  r.post("/class_sections", admin, async (c) => {
    const b = await body(c, sectionInput.partial({ homeroom_teacher_id: true }));
    const out = await asCaller(deps2, c, async (tx, me) => {
      const ins = await tx.query(
        `insert into class_sections (school_id, term_id, name, grade_level, homeroom_teacher_id)
         values ($1, $2, $3, $4, $5) returning id`,
        [me.schoolId, b.term_id, b.name, b.grade_level, b.homeroom_teacher_id ?? null]
      );
      return sectionById(tx, ins.rows[0].id);
    });
    return c.json(out, 201);
  });
  r.get("/class_sections/:id", async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const section = await sectionById(tx, id);
        const teachers = await tx.query(
          `select p.id, p.full_name, st.subject from section_teachers st join people p on p.id = st.teacher_id
            where st.section_id = $1 order by st.subject, p.full_name`,
          [id]
        );
        const roster = await tx.query(
          `select p.id, p.full_name,
                  (select round(100.0 * count(*) filter (where a.status in ('present', 'late')) / nullif(count(*), 0), 1)
                     from attendance_records a where a.student_id = p.id and a.class_section_id = $1) as rate
             from enrollments e join people p on p.id = e.student_id
            where e.class_section_id = $1 and e.status = 'active' order by p.full_name`,
          [id]
        );
        const overall = await tx.query(
          `select round(100.0 * count(*) filter (where status in ('present', 'late')) / nullif(count(*), 0), 1) as rate
             from attendance_records where class_section_id = $1`,
          [id]
        );
        return {
          ...section,
          teachers: teachers.rows.map((t) => ({ person: personRef({ ...t, role: "teacher" }), subject: t.subject })),
          roster: roster.rows.map((s) => ({ ...studentRef({ ...s, section_id: id, section_name: section.name }), attendance_rate_pct: num(s.rate) })),
          attendance_rate_pct: num(overall.rows[0]?.rate)
        };
      })
    );
  });
  r.patch("/class_sections/:id", admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, sectionInput.partial());
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const hasHomeroom = "homeroom_teacher_id" in b;
        const u = await tx.query(
          `update class_sections set name = coalesce($2, name), grade_level = coalesce($3, grade_level),
                  term_id = coalesce($4::uuid, term_id),
                  homeroom_teacher_id = case when $6 then $5::uuid else homeroom_teacher_id end
            where id = $1`,
          [id, b.name ?? null, b.grade_level ?? null, b.term_id ?? null, b.homeroom_teacher_id ?? null, hasHomeroom]
        );
        if (u.rowCount === 0) throw notFound("Class section");
        return sectionById(tx, id);
      })
    );
  });
  const periods = async (tx, sectionId) => {
    const rows = await tx.query(
      `select p.id, p.subject, p.weekday, p.starts_at, p.ends_at, t.id as tid, t.full_name as tname
         from periods p join people t on t.id = p.teacher_id
        where p.class_section_id = $1 order by p.weekday, p.starts_at`,
      [sectionId]
    );
    return rows.rows.map((p) => ({
      id: p.id,
      subject: p.subject,
      weekday: p.weekday,
      starts_at: hhmm(p.starts_at),
      ends_at: hhmm(p.ends_at),
      teacher: personRef({ id: p.tid, full_name: p.tname, role: "teacher" })
    }));
  };
  r.get("/class_sections/:id/periods", async (c) => {
    const id = idParam(c);
    return c.json({
      items: await asCaller(deps2, c, async (tx) => {
        await sectionById(tx, id);
        return periods(tx, id);
      })
    });
  });
  r.put("/class_sections/:id/periods", admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, z6.array(periodInput).max(100));
    return c.json({
      items: await asCaller(deps2, c, async (tx, me) => {
        await sectionById(tx, id);
        const existing = await tx.query(
          "select id, teacher_id, subject, weekday, starts_at from periods where class_section_id = $1",
          [id]
        );
        const key = (x) => `${x.teacher_id}|${x.subject}|${x.weekday}|${hhmm(x.starts_at)}`;
        const wanted = new Map(b.map((p) => [key({ ...p }), p]));
        const have = new Map(existing.rows.map((p) => [key(p), p.id]));
        for (const [k, p] of wanted) {
          if (have.has(k)) {
            await tx.query("update periods set ends_at = $2 where id = $1", [have.get(k), p.ends_at]);
          } else {
            await tx.query(
              `insert into periods (school_id, class_section_id, teacher_id, subject, weekday, starts_at, ends_at)
               values ($1, $2, $3, $4, $5, $6, $7)`,
              [me.schoolId, id, p.teacher_id, p.subject, p.weekday, p.starts_at, p.ends_at]
            );
          }
        }
        for (const [k, pid] of have) {
          if (wanted.has(k)) continue;
          try {
            await tx.attempt(() => tx.query("delete from periods where id = $1", [pid]));
          } catch (err) {
            if (err.code === "23503")
              throw conflict("A period with recorded attendance cannot be removed", "period_in_use");
            throw err;
          }
        }
        return periods(tx, id);
      })
    });
  });
  r.post("/enrollments", admin, async (c) => {
    const b = await body(c, z6.object({ student_id: uuid, class_section_id: uuid }));
    const out = await asCaller(deps2, c, async (tx, me) => {
      const e = await tx.query(
        `insert into enrollments (school_id, student_id, class_section_id, status) values ($1, $2, $3, 'active')
         on conflict (student_id, class_section_id) do update set status = 'active' where enrollments.status <> 'active'
         returning id, student_id, class_section_id, status`,
        [me.schoolId, b.student_id, b.class_section_id]
      );
      if (!e.rows[0]) throw conflict("That student is already enrolled in this section", "already_enrolled");
      return e.rows[0];
    });
    return c.json(out, 201);
  });
  r.delete("/enrollments/:id", admin, async (c) => {
    const id = idParam(c);
    await asCaller(deps2, c, async (tx) => {
      const e = await tx.query(`update enrollments set status = 'withdrawn' where id = $1`, [id]);
      if (e.rowCount === 0) throw notFound("Enrollment");
    });
    return c.body(null, 204);
  });
  r.post("/class_sections/:id/students/import", admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, z6.object({ students: z6.array(z6.object({ full_name: z6.string().trim().min(1).max(120) })).min(1).max(300) }));
    const items = await asCaller(deps2, c, async (tx, me) => {
      const out = [];
      for (const s of b.students) {
        const p = await tx.query(
          `insert into people (school_id, full_name, role) values ($1, $2, 'student') returning id`,
          [me.schoolId, s.full_name]
        );
        const studentId = p.rows[0].id;
        await tx.query(
          `insert into enrollments (school_id, student_id, class_section_id, status) values ($1, $2, $3, 'active')`,
          [me.schoolId, studentId, id]
        );
        out.push(studentRef({ id: studentId, full_name: s.full_name }));
      }
      return out;
    });
    return c.json({ items }, 201);
  });
  return r;
}

// src/modules/conferences/routes.ts
import { Hono as Hono6 } from "hono";
import { z as z7 } from "zod";
var MAX_SLOTS_PER_REQUEST = 100;
var SLOT_SELECT = `
  select s.id, s.teacher_id, t.full_name as teacher_name, s.starts_at, s.ends_at, s.booked_by_guardian_id,
         s.student_id, st.full_name as student_name
    from conference_slots s join people t on t.id = s.teacher_id left join people st on st.id = s.student_id`;
var toSlot = (s, meId) => ({
  id: s.id,
  teacher: personRef({ id: s.teacher_id, full_name: s.teacher_name, role: "teacher" }),
  starts_at: s.starts_at.toISOString(),
  ends_at: s.ends_at.toISOString(),
  booked: s.booked_by_guardian_id != null,
  booked_by_me: s.booked_by_guardian_id === meId,
  ...s.student_id && s.student_name ? { student: studentRef({ id: s.student_id, full_name: s.student_name }) } : {}
});
async function slotById(tx, id, meId) {
  const r = await tx.query(`${SLOT_SELECT} where s.id = $1`, [id]);
  if (!r.rows[0]) throw notFound("Conference slot");
  return toSlot(r.rows[0], meId);
}
function conferenceRoutes(deps2) {
  const r = new Hono6();
  r.get("/conference_slots", async (c) => {
    const q = query(c, z7.object({ teacher_id: uuid.optional(), from: isoDate.optional() }));
    return c.json({
      items: await asCaller(deps2, c, async (tx, me) => {
        const rows = await tx.query(
          `${SLOT_SELECT}
            where ($1::uuid is null or s.teacher_id = $1) and ($2::date is null or s.starts_at >= $2::date)
            order by s.starts_at, s.id`,
          [q.teacher_id ?? null, q.from ?? null]
        );
        return rows.rows.map((s) => toSlot(s, me.personId));
      })
    });
  });
  r.post("/conference_slots", requireRole("teacher", "admin"), async (c) => {
    const b = await body(
      c,
      z7.object({ teacher_id: uuid, starts_at: z7.iso.datetime(), ends_at: z7.iso.datetime(), slot_minutes: z7.number().int().min(5).max(120) })
    );
    const start = new Date(b.starts_at).getTime();
    const end = new Date(b.ends_at).getTime();
    const step = b.slot_minutes * 6e4;
    if (end <= start) throw unprocessable("The window must end after it starts", "invalid_window");
    if ((end - start) / step > MAX_SLOTS_PER_REQUEST) {
      throw unprocessable(`That would create more than ${MAX_SLOTS_PER_REQUEST} slots; use a shorter window`, "too_many_slots");
    }
    return c.json(
      { items: await asCaller(deps2, c, async (tx, me) => {
        try {
          const ins = await tx.attempt(
            () => tx.query(
              `insert into conference_slots (school_id, teacher_id, starts_at, ends_at)
               select app.school_id(), $1, t, t + ($4::int * interval '1 minute')
                 from generate_series($2::timestamptz, $3::timestamptz - ($4::int * interval '1 minute'), ($4::int * interval '1 minute')) t
               on conflict (teacher_id, starts_at) do nothing returning id`,
              [b.teacher_id, b.starts_at, b.ends_at, b.slot_minutes]
            )
          );
          const rows = await tx.query(`${SLOT_SELECT} where s.id = any($1::uuid[]) order by s.starts_at`, [ins.rows.map((x) => x.id)]);
          return rows.rows.map((s) => toSlot(s, me.personId));
        } catch (err) {
          if (err.code === "42501") throw forbidden("Teachers can only create slots for themselves", "not_your_slots");
          throw err;
        }
      }) },
      201
    );
  });
  r.put("/conference_slots/:id/booking", requireRole("guardian"), async (c) => {
    const id = idParam(c);
    const b = await body(c, z7.object({ student_id: uuid }));
    return c.json(
      await asCaller(deps2, c, async (tx, me) => {
        try {
          await tx.attempt(() => tx.query("select book_conference_slot($1, $2)", [id, b.student_id]));
        } catch (err) {
          if (err.code === "42501") throw notFound("Conference slot");
          throw err;
        }
        return slotById(tx, id, me.personId);
      })
    );
  });
  r.delete("/conference_slots/:id/booking", requireRole("guardian"), async (c) => {
    const id = idParam(c);
    await asCaller(deps2, c, (tx) => tx.query("select release_conference_slot($1)", [id]));
    return c.body(null, 204);
  });
  return r;
}

// src/modules/dev/routes.ts
import { Hono as Hono8 } from "hono";
import { z as z9 } from "zod";

// src/integrations/payments.ts
import { createHmac as createHmac2, timingSafeEqual as timingSafeEqual3 } from "node:crypto";
function hmacHex(algo, secret, body2) {
  return createHmac2(algo, secret).update(body2).digest("hex");
}
function safeEqualHex(a, b) {
  const x = Buffer.from(a, "utf8");
  const y = Buffer.from(b, "utf8");
  return x.length === y.length && timingSafeEqual3(x, y);
}
var SandboxGateway = class {
  name = "sandbox";
  #secret;
  #webUrl;
  constructor(secret, webUrl) {
    this.#secret = secret;
    this.#webUrl = webUrl;
  }
  async initiate(input) {
    if (input.method === "card") {
      const url = `${this.#webUrl}/#/parent/pay/sandbox?ref=${encodeURIComponent(input.reference)}`;
      return { type: "redirect", redirectUrl: url };
    }
    return {
      type: "prompt",
      message: `Approve the GH\xA2${input.amount} request on ${input.phone ?? "your phone"} (sandbox: no real charge)`
    };
  }
  verifyWebhook(rawBody, headers) {
    const sig = headers.get("x-signature");
    return !!sig && safeEqualHex(sig, hmacHex("sha256", this.#secret, rawBody));
  }
  parseWebhook(rawBody) {
    const e = JSON.parse(rawBody);
    const status2 = e.event === "payment.succeeded" ? "succeeded" : e.event === "payment.failed" ? "failed" : null;
    if (!status2 || !e.reference || !e.amount || !e.metadata?.invoice_id) return null;
    return {
      providerRef: e.reference,
      status: status2,
      amount: e.amount,
      method: e.method ?? "card",
      invoiceId: e.metadata.invoice_id
    };
  }
  /** Test/dev helper: produce a signed webhook as the gateway would send it. */
  sign(body2) {
    const raw = JSON.stringify(body2);
    return { body: raw, headers: { "content-type": "application/json", "x-signature": hmacHex("sha256", this.#secret, raw) } };
  }
};

// src/modules/fees/routes.ts
import { createHash as createHash4, randomUUID as randomUUID3 } from "node:crypto";
import { Hono as Hono7 } from "hono";
import { z as z8 } from "zod";
var moneyString = z8.string().regex(/^\d{1,9}(\.\d{1,2})?$/, "expected an amount like 600.00");
var cents = (s) => Math.round(Number(s) * 100);
var toFeeItem = (f) => ({ id: f.id, name: f.name, default_amount: money(f.default_amount), active: f.active });
var toPayment = (p) => ({
  id: p.id,
  invoice_id: p.invoice_id,
  amount: money(p.amount),
  method: p.method,
  status: p.status,
  provider_ref: p.provider_ref,
  paid_at: iso(p.paid_at),
  created_at: p.created_at.toISOString(),
  receipt_url: null,
  ...p.student_id && p.student_name ? { student: studentRef({ id: p.student_id, full_name: p.student_name }) } : {},
  ...p.description ? { description: p.description } : {}
});
var INVOICE_SELECT = `
  select i.id, i.student_id, st.full_name, i.term_id, i.description, i.amount_due, i.status, i.due_date, i.fee_item_id,
         coalesce((select sum(p.amount) from payments p where p.invoice_id = i.id and p.status = 'succeeded'), 0) as paid
    from invoices i join people st on st.id = i.student_id`;
function toInvoice(i, today, payments) {
  const outstanding = Math.max(0, cents(i.amount_due) - cents(i.paid));
  return {
    id: i.id,
    student: studentRef({ id: i.student_id, full_name: i.full_name }),
    term_id: i.term_id,
    description: i.description,
    amount_due: money(i.amount_due),
    amount_paid: money(i.paid),
    outstanding: (outstanding / 100).toFixed(2),
    status: i.status,
    due_date: i.due_date,
    overdue: i.status !== "void" && outstanding > 0 && i.due_date < today,
    fee_item_id: i.fee_item_id,
    payments
  };
}
async function withPayments(tx, rows, today) {
  if (rows.length === 0) return [];
  const pays = await tx.query(
    `select id, invoice_id, amount, method, status, provider_ref, paid_at, created_at from payments
      where invoice_id = any($1::uuid[]) order by created_at, id`,
    [rows.map((r) => r.id)]
  );
  const by = /* @__PURE__ */ new Map();
  for (const p of pays.rows) by.set(p.invoice_id, [...by.get(p.invoice_id) ?? [], toPayment(p)]);
  return rows.map((r) => toInvoice(r, today, by.get(r.id) ?? []));
}
var feeItemInput = z8.object({
  name: z8.string().min(1).max(120),
  default_amount: moneyString,
  active: z8.boolean().default(true)
});
function feesRoutes(deps2) {
  const r = new Hono7();
  const admin = requireRole("admin");
  const money_ = requireRole("admin", "guardian");
  r.get(
    "/fee_items",
    admin,
    async (c) => c.json({
      items: await asCaller(deps2, c, async (tx) => {
        const rows = await tx.query("select id, name, default_amount, active from fee_items order by name");
        return rows.rows.map(toFeeItem);
      })
    })
  );
  r.post("/fee_items", admin, async (c) => {
    const b = await body(c, feeItemInput);
    const out = await asCaller(deps2, c, async (tx, me) => {
      const row = await tx.query(
        `insert into fee_items (school_id, name, default_amount, active) values ($1, $2, $3, $4)
         returning id, name, default_amount, active`,
        [me.schoolId, b.name, b.default_amount, b.active]
      );
      return toFeeItem(row.rows[0]);
    });
    return c.json(out, 201);
  });
  r.patch("/fee_items/:id", admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, feeItemInput.partial());
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const row = await tx.query(
          `update fee_items set name = coalesce($2, name), default_amount = coalesce($3, default_amount), active = coalesce($4, active)
            where id = $1 returning id, name, default_amount, active`,
          [id, b.name ?? null, b.default_amount ?? null, b.active ?? null]
        );
        if (!row.rows[0]) throw notFound("Fee item");
        return toFeeItem(row.rows[0]);
      })
    );
  });
  r.get("/students/:id/invoices", money_, async (c) => {
    const id = idParam(c);
    return c.json({
      items: await asCaller(deps2, c, async (tx) => {
        await visibleStudent(tx, id, "student_invoices");
        const today = todayIn(await schoolTimezone(tx), deps2.clock.now());
        const rows = await tx.query(`${INVOICE_SELECT} where i.student_id = $1 order by i.due_date desc, i.id`, [id]);
        return withPayments(tx, rows.rows, today);
      })
    });
  });
  r.get("/invoices", admin, async (c) => {
    const q = query(
      c,
      pageQuery.extend({ status: z8.enum(["unpaid", "partial", "paid", "void", "overdue"]).optional(), term_id: uuid.optional() })
    );
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const today = todayIn(await schoolTimezone(tx), deps2.clock.now());
        const params = [q.limit + 1];
        const where = [];
        if (q.term_id) {
          params.push(q.term_id);
          where.push(`x.term_id = $${params.length}`);
        }
        if (q.status === "overdue") {
          params.push(today);
          where.push(`x.status <> 'void' and x.amount_due - x.paid > 0 and x.due_date < $${params.length}::date`);
        } else if (q.status) {
          params.push(q.status);
          where.push(`x.status = $${params.length}::invoice_status`);
        }
        if (cur) {
          params.push(cur.t, cur.id);
          where.push(`(x.due_date, x.id) < ($${params.length - 1}::date, $${params.length}::uuid)`);
        }
        const rows = await tx.query(
          `select * from (${INVOICE_SELECT}) x ${where.length ? "where " + where.join(" and ") : ""}
            order by x.due_date desc, x.id desc limit $1`,
          params
        );
        const page = paginate(rows.rows, q.limit, (i) => i.due_date);
        return { items: await withPayments(tx, page.items, today), next_cursor: page.next_cursor };
      })
    );
  });
  r.post("/invoices", admin, async (c) => {
    const b = await body(
      c,
      z8.object({
        student_id: uuid.optional(),
        class_section_id: uuid.optional(),
        term_id: uuid,
        description: z8.string().min(1).max(200),
        amount_due: moneyString,
        due_date: z8.string().regex(/^\d{4}-\d{2}-\d{2}$/),
        fee_item_id: uuid.optional()
      })
    );
    if (!!b.student_id === !!b.class_section_id) {
      throw unprocessable("Give exactly one of student_id or class_section_id", "invalid_target");
    }
    const items = await asCaller(deps2, c, async (tx) => {
      const ids = b.student_id ? await tx.query(
        `insert into invoices (school_id, student_id, term_id, description, amount_due, due_date, fee_item_id)
             values (app.school_id(), $1, $2, $3, $4, $5, $6) returning id`,
        [b.student_id, b.term_id, b.description, b.amount_due, b.due_date, b.fee_item_id ?? null]
      ) : await tx.query(
        `insert into invoices (school_id, student_id, term_id, description, amount_due, due_date, fee_item_id)
             select app.school_id(), e.student_id, $2, $3, $4, $5, $6 from enrollments e
              where e.class_section_id = $1 and e.status = 'active' returning id`,
        [b.class_section_id, b.term_id, b.description, b.amount_due, b.due_date, b.fee_item_id ?? null]
      );
      const today = todayIn(await schoolTimezone(tx), deps2.clock.now());
      const rows = await tx.query(`${INVOICE_SELECT} where i.id = any($1::uuid[]) order by st.full_name`, [ids.rows.map((x) => x.id)]);
      return withPayments(tx, rows.rows, today);
    });
    return c.json({ items }, 201);
  });
  r.post("/invoices/:id/pay", requireRole("guardian"), async (c) => {
    const invoiceId = idParam(c);
    const b = await body(c, z8.object({ amount: moneyString, method: z8.enum(["card", "mtn_momo", "telecel_cash"]), phone: z8.string().min(6).max(25).optional() }));
    const prep = await asCaller(deps2, c, async (tx, me) => {
      const inv = await tx.query(`${INVOICE_SELECT} where i.id = $1`, [invoiceId]);
      const row = inv.rows[0];
      if (!row) throw notFound("Invoice");
      if (row.status === "void" || row.status === "paid") throw conflict("This invoice needs no further payment", "invoice_settled");
      const outstanding = cents(row.amount_due) - cents(row.paid);
      const amount = cents(b.amount);
      if (amount <= 0 || amount > outstanding) {
        throw unprocessable(`Enter an amount between 0.01 and ${(outstanding / 100).toFixed(2)}`, "amount_exceeds_balance");
      }
      const contact = await tx.query(
        "select phone, email from person_contacts where person_id = $1",
        [me.personId]
      );
      const phone = b.phone ?? contact.rows[0]?.phone ?? void 0;
      if (b.method !== "card" && !phone) throw unprocessable("A mobile number is needed for mobile money", "phone_required");
      return { phone, email: contact.rows[0]?.email ?? void 0, amount: (amount / 100).toFixed(2) };
    });
    const reference = `HR-${randomUUID3()}`;
    await deps2.db.asService(
      (tx) => tx.query(`select apply_payment_webhook($1, $2, $3, $4::payment_method, 'pending')`, [reference, invoiceId, prep.amount, b.method])
    );
    let next;
    try {
      const res = await deps2.payments.initiate({
        reference,
        amount: prep.amount,
        currency: "GHS",
        method: b.method,
        phone: prep.phone,
        email: prep.email,
        callbackUrl: `${deps2.config.PUBLIC_WEB_URL}/#/parent/fees`,
        metadata: { invoice_id: invoiceId }
      });
      next = res.type === "redirect" ? { type: "redirect", redirect_url: res.redirectUrl } : { type: "prompt", message: res.message };
    } catch (err) {
      c.var.log.error("payment gateway initiate failed", { err, reference });
      await deps2.db.asService(
        (tx) => tx.query(`select apply_payment_webhook($1, $2, $3, $4::payment_method, 'failed')`, [reference, invoiceId, prep.amount, b.method])
      );
      throw new AppError(502, "gateway_unavailable", "The payment provider could not be reached. Nothing was charged.");
    }
    const pay = await deps2.db.asService(
      (tx) => tx.query("select id, invoice_id, amount, method, status, provider_ref, paid_at, created_at from payments where provider_ref = $1", [reference])
    );
    return c.json({ payment: toPayment(pay.rows[0]), next }, 202);
  });
  r.get("/payments", admin, async (c) => {
    const q = query(c, pageQuery.extend({ status: z8.enum(["pending", "succeeded", "failed"]).optional(), stale_pending: z8.enum(["true", "false"]).optional() }));
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const params = [q.limit + 1];
        const where = [];
        if (q.status) {
          params.push(q.status);
          where.push(`status = $${params.length}::payment_status`);
        }
        if (q.stale_pending === "true") {
          params.push(new Date(deps2.clock.now().getTime() - 30 * 60 * 1e3));
          where.push(`status = 'pending' and created_at < $${params.length}`);
        }
        if (cur) {
          params.push(cur.t, cur.id);
          where.push(`(created_at, id) < ($${params.length - 1}::timestamptz, $${params.length}::uuid)`);
        }
        const rows = await tx.query(
          `select * from (
             select p.id, p.invoice_id, p.amount, p.method, p.status, p.provider_ref, p.paid_at, p.created_at,
                    i.student_id, st.full_name as student_name, i.description
               from payments p join invoices i on i.id = p.invoice_id join people st on st.id = i.student_id) p
            ${where.length ? "where " + where.join(" and ") : ""} order by created_at desc, id desc limit $1`,
          params
        );
        const page = paginate(rows.rows, q.limit, (p) => p.created_at.toISOString());
        return { items: page.items.map(toPayment), next_cursor: page.next_cursor };
      })
    );
  });
  r.post("/payments", admin, async (c) => {
    const b = await body(c, z8.object({ invoice_id: uuid, amount: moneyString, reference: z8.string().min(1).max(80) }));
    const out = await asCaller(deps2, c, async (tx) => {
      const inv = await tx.query("select 1 from invoices where id = $1", [b.invoice_id]);
      if (inv.rowCount === 0) throw notFound("Invoice");
      return true;
    }).then(async () => {
      const ref = `manual:${b.reference}`;
      await deps2.db.asService(
        (tx) => tx.query(`select apply_payment_webhook($1, $2, $3, 'manual', 'succeeded')`, [ref, b.invoice_id, b.amount])
      );
      const p = await deps2.db.asService(
        (tx) => tx.query("select id, invoice_id, amount, method, status, provider_ref, paid_at, created_at from payments where provider_ref = $1", [ref])
      );
      return toPayment(p.rows[0]);
    });
    return c.json(out, 201);
  });
  r.get("/payments/:id", money_, async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const p = await tx.query("select id, invoice_id, amount, method, status, provider_ref, paid_at, created_at from payments where id = $1", [id]);
        if (!p.rows[0]) throw notFound("Payment");
        return toPayment(p.rows[0]);
      })
    );
  });
  return r;
}
function webhookRoutes(deps2) {
  const r = new Hono7();
  r.post("/payment", async (c) => {
    const raw = await c.req.text();
    const sha = createHash4("sha256").update(raw).digest("hex");
    const record = (outcome, extra = {}) => deps2.db.asService(
      (tx) => tx.query(
        `insert into webhook_events (provider, outcome, provider_ref, invoice_id, body_sha256, detail) values ($1, $2, $3, $4, $5, $6)`,
        [deps2.payments.name, outcome, extra.ref ?? null, extra.invoice ?? null, sha, extra.detail ?? null]
      )
    );
    if (!deps2.payments.verifyWebhook(raw, c.req.raw.headers)) {
      await record("invalid_signature");
      c.var.log.warn("payment webhook rejected: bad signature", { sha });
      throw unauthorized("Invalid signature", "invalid_signature");
    }
    let event;
    try {
      event = deps2.payments.parseWebhook(raw);
    } catch (err) {
      await record("error", { detail: "unparseable body" });
      throw new AppError(400, "invalid_webhook", `Could not parse webhook: ${err.message}`);
    }
    if (!event) {
      await record("ignored");
      return c.body(null, 200);
    }
    try {
      await deps2.db.asService(
        (tx) => tx.query(`select apply_payment_webhook($1, $2, $3, $4::payment_method, $5::payment_status)`, [
          event.providerRef,
          event.invoiceId,
          event.amount,
          event.method,
          event.status
        ])
      );
      await record("processed", { ref: event.providerRef, invoice: event.invoiceId });
    } catch (err) {
      const code = err.code;
      if (code === "P0002" || code === "22P02") {
        await record("unmatched", { ref: event.providerRef, detail: err.message });
        c.var.log.warn("payment webhook for unknown invoice", { ref: event.providerRef, invoice: event.invoiceId });
        return c.body(null, 200);
      }
      await record("error", { ref: event.providerRef, invoice: event.invoiceId, detail: err.message });
      throw err;
    }
    return c.body(null, 200);
  });
  return r;
}

// src/modules/dev/routes.ts
function devRoutes(deps2) {
  if (deps2.config.NODE_ENV === "production" || !(deps2.payments instanceof SandboxGateway)) return null;
  const gateway = deps2.payments;
  const r = new Hono8();
  const webhook = webhookRoutes(deps2);
  r.post("/sandbox/complete", async (c) => {
    const b = await body(c, z9.object({ reference: z9.string().min(1).max(100), outcome: z9.enum(["succeeded", "failed"]) }));
    const pay = await deps2.db.asService(
      (tx) => tx.query(
        "select invoice_id, amount, method from payments where provider_ref = $1",
        [b.reference]
      )
    );
    const p = pay.rows[0];
    if (!p) throw notFound("Payment");
    const signed = gateway.sign({
      event: b.outcome === "succeeded" ? "payment.succeeded" : "payment.failed",
      reference: b.reference,
      amount: p.amount,
      method: p.method,
      metadata: { invoice_id: p.invoice_id }
    });
    const res = await webhook.request("/payment", { method: "POST", headers: signed.headers, body: signed.body });
    if (!res.ok) throw new AppError(res.status, "sandbox_failed", `The webhook handler answered ${res.status}`);
    return c.body(null, 204);
  });
  return r;
}

// src/modules/gradebook/routes.ts
import { Hono as Hono9 } from "hono";
import { z as z10 } from "zod";
var assessmentInput = z10.object({
  subject: z10.string().min(1).max(60),
  title: z10.string().min(1).max(120),
  weight: z10.number().gt(0).max(100),
  max_score: z10.number().gt(0).max(1e5),
  due_date: isoDate.nullable().optional()
});
var toAssessment = (a) => ({
  id: a.id,
  subject: a.subject,
  title: a.title,
  weight: Number(a.weight),
  max_score: Number(a.max_score),
  due_date: a.due_date
});
var termClosed = () => new AppError(403, "term_closed", "This term is closed; its gradebook can no longer be changed");
async function visibleSection2(tx, id) {
  const r = await tx.query(
    `select cs.id, t.closed as term_closed from class_sections cs join terms t on t.id = cs.term_id where cs.id = $1`,
    [id]
  );
  if (!r.rows[0]) throw notFound("Class section");
  return r.rows[0];
}
function gradebookRoutes(deps2) {
  const r = new Hono9();
  const staff = requireRole("teacher", "admin");
  const teacher = requireRole("teacher");
  async function weightTotal(tx, sectionId, subject, excludeId) {
    const t = await tx.query(
      `select coalesce(sum(weight), 0) as total from assessments
        where class_section_id = $1 and subject = $2 and ($3::uuid is null or id <> $3)`,
      [sectionId, subject, excludeId]
    );
    return Number(t.rows[0]?.total ?? 0);
  }
  r.get("/class_sections/:id/gradebook", staff, async (c) => {
    const id = idParam(c);
    const q = query(c, z10.object({ subject: z10.string().max(60).optional() }));
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const section = await visibleSection2(tx, id);
        const assessments = await tx.query(
          `select id, class_section_id, subject, title, weight, max_score, due_date from assessments
            where class_section_id = $1 and ($2::text is null or subject = $2)
            order by due_date nulls last, title`,
          [id, q.subject ?? null]
        );
        const students = await tx.query(
          `select p.id, p.full_name from enrollments e join people p on p.id = e.student_id
            where e.class_section_id = $1 and e.status = 'active' order by p.full_name`,
          [id]
        );
        const grades = await tx.query(
          `select g.assessment_id, g.student_id, g.score from grades g
             join assessments a on a.id = g.assessment_id
            where a.class_section_id = $1 and ($2::text is null or a.subject = $2)`,
          [id, q.subject ?? null]
        );
        const byStudent = /* @__PURE__ */ new Map();
        for (const g of grades.rows) {
          if (!byStudent.has(g.student_id)) byStudent.set(g.student_id, /* @__PURE__ */ new Map());
          byStudent.get(g.student_id).set(g.assessment_id, g.score == null ? null : Number(g.score));
        }
        const meta = assessments.rows.map((a) => ({ id: a.id, weight: Number(a.weight), max_score: Number(a.max_score) }));
        const bandRows = await tx.query(
          "select label, min_score, max_score from grade_bands"
        );
        const bands = bandRows.rows.map((b) => ({ label: b.label, min_score: Number(b.min_score), max_score: Number(b.max_score) }));
        return {
          class_section_id: id,
          term_closed: section.term_closed,
          assessments: assessments.rows.map(toAssessment),
          rows: students.rows.map((s) => {
            const scores = byStudent.get(s.id) ?? /* @__PURE__ */ new Map();
            const running = runningGrade(meta.map((m) => ({ score: scores.get(m.id) ?? null, max_score: m.max_score, weight: m.weight })));
            return {
              student: studentRef(s),
              scores: Object.fromEntries(meta.map((m) => [m.id, scores.get(m.id) ?? null])),
              running_grade: running,
              grade_band: gradeBandFor(running, bands)
            };
          })
        };
      })
    );
  });
  r.post("/class_sections/:id/assessments", teacher, async (c) => {
    const id = idParam(c);
    const b = await body(c, assessmentInput);
    const out = await asCaller(deps2, c, async (tx, me) => {
      if ((await visibleSection2(tx, id)).term_closed) throw termClosed();
      if (await weightTotal(tx, id, b.subject, null) + b.weight > 100) {
        throw unprocessable("The weights for this subject would add up to more than 100%", "weights_exceed_100");
      }
      const a = await tx.query(
        `insert into assessments (school_id, class_section_id, subject, title, weight, max_score, due_date)
         values ($1, $2, $3, $4, $5, $6, $7)
         returning id, class_section_id, subject, title, weight, max_score, due_date`,
        [me.schoolId, id, b.subject, b.title, b.weight, b.max_score, b.due_date ?? null]
      );
      return toAssessment(a.rows[0]);
    });
    return c.json(out, 201);
  });
  r.patch("/assessments/:id", teacher, async (c) => {
    const id = idParam(c);
    const b = await body(c, assessmentInput.partial());
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const cur = await tx.query(
          `select a.id, a.class_section_id, a.subject, a.title, a.weight, a.max_score, a.due_date, t.closed as term_closed
             from assessments a join class_sections cs on cs.id = a.class_section_id join terms t on t.id = cs.term_id
            where a.id = $1`,
          [id]
        );
        const a = cur.rows[0];
        if (!a) throw notFound("Assessment");
        if (a.term_closed) throw termClosed();
        const subject = b.subject ?? a.subject;
        const weight = b.weight ?? Number(a.weight);
        if (await weightTotal(tx, a.class_section_id, subject, id) + weight > 100) {
          throw unprocessable("The weights for this subject would add up to more than 100%", "weights_exceed_100");
        }
        const u = await tx.query(
          `update assessments set subject = $2, title = $3, weight = $4, max_score = $5,
                  due_date = case when $7 then $6::date else due_date end
            where id = $1 returning id, class_section_id, subject, title, weight, max_score, due_date`,
          [id, subject, b.title ?? a.title, weight, b.max_score ?? Number(a.max_score), b.due_date ?? null, "due_date" in b]
        );
        if (!u.rows[0]) throw notFound("Assessment");
        return toAssessment(u.rows[0]);
      })
    );
  });
  r.get("/assessments/:id/grades", staff, async (c) => {
    const id = idParam(c);
    return c.json({
      items: await asCaller(deps2, c, async (tx) => {
        const a = await tx.query("select 1 from assessments where id = $1", [id]);
        if (a.rowCount === 0) throw notFound("Assessment");
        const rows = await tx.query(
          "select student_id, assessment_id, score, comment from grades where assessment_id = $1",
          [id]
        );
        return rows.rows.map((g) => ({
          student_id: g.student_id,
          assessment_id: g.assessment_id,
          score: g.score == null ? null : Number(g.score),
          comment: g.comment
        }));
      })
    });
  });
  r.patch("/assessments/:id/grades", teacher, async (c) => {
    const id = idParam(c);
    const b = await body(
      c,
      z10.object({
        grades: z10.array(z10.object({ student_id: uuid, score: z10.number().min(0).nullable().optional(), comment: z10.string().max(1e3).nullable().optional() })).min(1).max(200)
      })
    );
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const a = await tx.query(
          `select t.closed as term_closed from assessments a
             join class_sections cs on cs.id = a.class_section_id join terms t on t.id = cs.term_id where a.id = $1`,
          [id]
        );
        if (!a.rows[0]) throw notFound("Assessment");
        if (a.rows[0].term_closed) throw termClosed();
        const results = [];
        let applied = 0;
        let rejected = 0;
        for (const g of b.grades) {
          try {
            await tx.attempt(
              () => tx.query(
                `insert into grades (school_id, assessment_id, student_id, score, comment)
                 values (app.school_id(), $1, $2, $3, $4)
                 on conflict (assessment_id, student_id) do update set
                   score = case when $5 then excluded.score else grades.score end,
                   comment = case when $6 then excluded.comment else grades.comment end,
                   updated_at = $7`,
                [id, g.student_id, g.score ?? null, g.comment ?? null, "score" in g, "comment" in g, deps2.clock.now()]
              )
            );
            applied++;
            results.push({ student_id: g.student_id, outcome: "applied" });
          } catch (err) {
            const code = err.code;
            if (!["42501", "23514", "23503"].includes(code ?? "")) throw err;
            rejected++;
            results.push({
              student_id: g.student_id,
              outcome: "rejected",
              code: code === "23514" ? "score_out_of_range" : code === "42501" ? "not_enrolled" : "unknown_student",
              message: code === "23514" ? err.message : code === "42501" ? "This student is not enrolled in the section" : "No such student"
            });
          }
        }
        return { applied, rejected, results };
      })
    );
  });
  return r;
}

// src/modules/grading/routes.ts
import { Hono as Hono10 } from "hono";
import { z as z11 } from "zod";
var bandBase = z11.object({
  label: z11.string().min(1).max(40),
  min_score: z11.number().min(0).max(1e5),
  max_score: z11.number().min(0).max(1e5)
});
var toBand = (b) => ({ id: b.id, label: b.label, min_score: Number(b.min_score), max_score: Number(b.max_score) });
function gradingRoutes(deps2) {
  const r = new Hono10();
  const admin = requireRole("admin");
  r.get(
    "/grade_bands",
    async (c) => c.json({
      items: await asCaller(deps2, c, async (tx) => {
        const rows = await tx.query("select id, label, min_score, max_score from grade_bands order by min_score desc");
        return rows.rows.map(toBand);
      })
    })
  );
  r.post("/grade_bands", admin, async (c) => {
    const b = await body(c, bandBase);
    if (b.min_score > b.max_score) throw unprocessable("min_score must not exceed max_score", "invalid_range");
    const out = await asCaller(deps2, c, async (tx, me) => {
      const row = await tx.query(
        `insert into grade_bands (school_id, label, min_score, max_score) values ($1, $2, $3, $4)
         returning id, label, min_score, max_score`,
        [me.schoolId, b.label, b.min_score, b.max_score]
      );
      return toBand(row.rows[0]);
    });
    return c.json(out, 201);
  });
  r.patch("/grade_bands/:id", admin, async (c) => {
    const id = idParam(c);
    const b = await body(c, bandBase.partial());
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const cur = await tx.query("select id, label, min_score, max_score from grade_bands where id = $1", [id]);
        const existing = cur.rows[0];
        if (!existing) throw notFound("Grade band");
        const min = b.min_score ?? Number(existing.min_score);
        const max = b.max_score ?? Number(existing.max_score);
        if (min > max) throw unprocessable("min_score must not exceed max_score", "invalid_range");
        const row = await tx.query(
          `update grade_bands set label = $2, min_score = $3, max_score = $4 where id = $1
           returning id, label, min_score, max_score`,
          [id, b.label ?? existing.label, min, max]
        );
        return toBand(row.rows[0]);
      })
    );
  });
  r.delete("/grade_bands/:id", admin, async (c) => {
    const id = idParam(c);
    await asCaller(deps2, c, async (tx) => {
      const del = await tx.query("delete from grade_bands where id = $1", [id]);
      if (del.rowCount === 0) throw notFound("Grade band");
    });
    return c.body(null, 204);
  });
  return r;
}

// src/modules/homework/routes.ts
import { Hono as Hono11 } from "hono";
import { z as z12 } from "zod";
var HW_SELECT = `
  select h.id, h.class_section_id, h.title, h.body, h.due_date, h.posted_by, p.full_name as poster_name,
         (select string_agg(st.subject, ', ' order by st.subject) from section_teachers st
           where st.section_id = h.class_section_id and st.teacher_id = h.posted_by and st.subject <> 'Homeroom') as subject
    from homework h left join people p on p.id = h.posted_by`;
var toHomework = (h) => ({
  id: h.id,
  class_section_id: h.class_section_id,
  subject: h.subject,
  title: h.title,
  body: h.body,
  due_date: h.due_date,
  ...h.poster_name ? { posted_by: personRef({ id: h.posted_by, full_name: h.poster_name, role: "teacher" }) } : {}
});
function homeworkRoutes(deps2) {
  const r = new Hono11();
  r.get("/class_sections/:id/homework", requireRole("teacher", "admin"), async (c) => {
    const id = idParam(c);
    return c.json({
      items: await asCaller(deps2, c, async (tx) => {
        const s = await tx.query("select 1 from class_sections where id = $1", [id]);
        if (s.rowCount === 0) throw notFound("Class section");
        const rows = await tx.query(`${HW_SELECT} where h.class_section_id = $1 order by h.due_date desc, h.id`, [id]);
        return rows.rows.map(toHomework);
      })
    });
  });
  r.post("/class_sections/:id/homework", requireRole("teacher"), async (c) => {
    const id = idParam(c);
    const b = await body(c, z12.object({ title: z12.string().trim().min(1).max(200), body: z12.string().max(5e3).optional(), due_date: isoDate }));
    const out = await asCaller(deps2, c, async (tx, me) => {
      const s = await tx.query("select 1 from class_sections where id = $1", [id]);
      if (s.rowCount === 0) throw notFound("Class section");
      try {
        const ins = await tx.attempt(
          () => tx.query(
            `insert into homework (school_id, class_section_id, title, body, due_date, posted_by, created_at)
             values (app.school_id(), $1, $2, $3, $4, $5, $6) returning id`,
            [id, b.title, b.body ?? null, b.due_date, me.personId, deps2.clock.now()]
          )
        );
        const rows = await tx.query(`${HW_SELECT} where h.id = $1`, [ins.rows[0].id]);
        return toHomework(rows.rows[0]);
      } catch (err) {
        if (err.code === "42501") throw forbidden("You can only post homework to a class you teach, in an open term", "cannot_post_here");
        throw err;
      }
    });
    return c.json(out, 201);
  });
  r.get("/students/:id/homework", async (c) => {
    const id = idParam(c);
    const q = query(c, z12.object({ due_from: isoDate.optional() }));
    return c.json({
      items: await asCaller(deps2, c, async (tx) => {
        await visibleStudent(tx, id, "student_homework");
        const rows = await tx.query(
          `${HW_SELECT}
            where h.class_section_id in (select class_section_id from enrollments where student_id = $1 and status = 'active')
              and ($2::date is null or h.due_date >= $2)
            order by h.due_date, h.id`,
          [id, q.due_from ?? null]
        );
        return rows.rows.map(toHomework);
      })
    });
  });
  return r;
}

// src/modules/me/routes.ts
import { Hono as Hono12 } from "hono";
import { z as z13 } from "zod";
var prefsSchema = z13.object({ push: z13.boolean(), email: z13.boolean(), sms: z13.boolean() });
function meRoutes(deps2) {
  const r = new Hono12();
  r.get("/me", async (c) => c.json(await asCaller(deps2, c, (tx, me) => loadMe(tx, me.personId, deps2.clock.now()))));
  r.get(
    "/me/notification_prefs",
    async (c) => c.json(
      await asCaller(deps2, c, async (tx, me) => {
        const p = await tx.query(
          "select push, email, sms from notification_prefs where person_id = $1",
          [me.personId]
        );
        return p.rows[0] ?? { push: true, email: true, sms: true };
      })
    )
  );
  r.put("/me/notification_prefs", async (c) => {
    const prefs = await body(c, prefsSchema);
    return c.json(
      await asCaller(deps2, c, async (tx, me) => {
        await tx.query(
          `insert into notification_prefs (person_id, push, email, sms) values ($1, $2, $3, $4)
           on conflict (person_id) do update set push = excluded.push, email = excluded.email, sms = excluded.sms`,
          [me.personId, prefs.push, prefs.email, prefs.sms]
        );
        return prefs;
      })
    );
  });
  r.put("/me/contact", async (c) => {
    const b = await body(c, z13.object({ phone: z13.string().nullable().optional(), email: z13.email().nullable().optional() }));
    return c.json(
      await asCaller(deps2, c, async (tx, me) => {
        const cur = await tx.query(
          "select phone, email from person_contacts where person_id = $1",
          [me.personId]
        );
        const prev = cur.rows[0] ?? { phone: null, email: null };
        const phone = b.phone === void 0 ? prev.phone : b.phone === null ? null : normalizePhone(b.phone, deps2.config.DEFAULT_COUNTRY_CODE);
        const email = b.email === void 0 ? prev.email : b.email === null ? null : b.email.toLowerCase();
        await tx.query(
          `insert into person_contacts (person_id, school_id, phone, email) values ($1, $2, $3, $4)
           on conflict (person_id) do update set phone = excluded.phone, email = excluded.email`,
          [me.personId, me.schoolId, phone, email]
        );
        return { phone, email };
      })
    );
  });
  r.post("/me/push_tokens", async (c) => {
    const b = await body(c, z13.object({ token: z13.string().min(10).max(4096), platform: z13.enum(["ios", "android", "web"]) }));
    await asCaller(
      deps2,
      c,
      (tx, me) => tx.query(
        `insert into push_tokens (person_id, token, platform) values ($1, $2, $3)
         on conflict (token) do update set person_id = excluded.person_id, platform = excluded.platform`,
        [me.personId, b.token, b.platform]
      )
    );
    return c.body(null, 204);
  });
  r.delete("/me/push_tokens/:token", async (c) => {
    await asCaller(
      deps2,
      c,
      (tx, me) => tx.query("delete from push_tokens where token = $1 and person_id = $2", [c.req.param("token"), me.personId])
    );
    return c.body(null, 204);
  });
  r.get("/notifications", async (c) => {
    const q = query(c, pageQuery.extend({ unread: z13.enum(["true", "false"]).optional() }));
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps2, c, async (tx, me) => {
        const params = [me.personId, q.limit + 1];
        let where = "person_id = $1";
        if (q.unread === "true") where += " and read_at is null";
        if (cur) {
          params.push(cur.t, cur.id);
          where += ` and (created_at, id) < ($3::timestamptz, $4::uuid)`;
        }
        const rows = await tx.query(
          `select id, kind, title, body, data, read_at, created_at from notifications
            where ${where} order by created_at desc, id desc limit $2`,
          params
        );
        const unread = await tx.query(
          "select count(*)::int as n from notifications where person_id = $1 and read_at is null",
          [me.personId]
        );
        const page = paginate(rows.rows, q.limit, (n) => n.created_at.toISOString());
        return {
          items: page.items.map((n) => ({
            id: n.id,
            kind: n.kind,
            title: n.title,
            body: n.body,
            data: n.data,
            read_at: iso(n.read_at),
            created_at: n.created_at.toISOString()
          })),
          next_cursor: page.next_cursor,
          unread_count: unread.rows[0]?.n ?? 0
        };
      })
    );
  });
  r.post("/notifications/read", async (c) => {
    const b = await body(c, z13.object({ ids: z13.array(uuid).max(500).optional() }));
    await asCaller(
      deps2,
      c,
      (tx, me) => b.ids ? tx.query("update notifications set read_at = $3 where person_id = $1 and id = any($2::uuid[]) and read_at is null", [me.personId, b.ids, deps2.clock.now()]) : tx.query("update notifications set read_at = $2 where person_id = $1 and read_at is null", [me.personId, deps2.clock.now()])
    );
    return c.body(null, 204);
  });
  return r;
}

// src/modules/messaging/routes.ts
import { Hono as Hono13 } from "hono";
import { z as z14 } from "zod";
var toThread = (t) => ({
  id: t.id,
  student: studentRef({ id: t.student_id, full_name: t.student_name }),
  teacher: personRef({ id: t.teacher_id, full_name: t.teacher_name, role: "teacher" }),
  guardian: personRef({ id: t.guardian_id, full_name: t.guardian_name, role: "guardian" }),
  ...t.m_id && t.m_sender && t.m_body && t.m_at ? { last_message: { id: t.m_id, thread_id: t.id, sender_id: t.m_sender, body: t.m_body, created_at: t.m_at.toISOString() } } : {},
  unread: t.unread
});
var THREAD_SELECT = `
  select t.id, t.student_id, st.full_name as student_name, t.teacher_id, te.full_name as teacher_name,
         t.guardian_id, g.full_name as guardian_name,
         lm.id as m_id, lm.sender_id as m_sender, lm.body as m_body, lm.created_at as m_at,
         case when app.role() = 'admin' then 0 else (select count(*)::int from messages m
           where m.thread_id = t.id and m.sender_id <> app.person_id()
             and m.created_at > coalesce((select tr.last_read_at from thread_reads tr
                                           where tr.thread_id = t.id and tr.person_id = app.person_id()), '-infinity'::timestamptz)) end as unread
    from message_threads t
    join people st on st.id = t.student_id
    join people te on te.id = t.teacher_id
    join people g on g.id = t.guardian_id
    left join lateral (select m.id, m.sender_id, m.body, m.created_at from messages m
                        where m.thread_id = t.id order by m.created_at desc, m.id desc limit 1) lm on true`;
async function threadById(tx, id) {
  const r = await tx.query(`${THREAD_SELECT} where t.id = $1`, [id]);
  if (!r.rows[0]) throw notFound("Thread");
  return toThread(r.rows[0]);
}
function messagingRoutes(deps2) {
  const r = new Hono13();
  r.get("/threads", async (c) => {
    const q = query(c, z14.object({ student_id: uuid.optional() }));
    return c.json({
      items: await asCaller(deps2, c, async (tx) => {
        const rows = await tx.query(
          `${THREAD_SELECT} where ($1::uuid is null or t.student_id = $1)
            order by coalesce(lm.created_at, t.created_at) desc, t.id`,
          [q.student_id ?? null]
        );
        return rows.rows.map(toThread);
      })
    });
  });
  r.post("/threads", async (c) => {
    const b = await body(c, z14.object({ student_id: uuid, other_party_id: uuid }));
    const { thread, created } = await asCaller(deps2, c, async (tx, me) => {
      if (me.role !== "teacher" && me.role !== "guardian") throw forbidden("Only teachers and guardians can start a conversation");
      const teacherId = me.role === "teacher" ? me.personId : b.other_party_id;
      const guardianId = me.role === "guardian" ? me.personId : b.other_party_id;
      const existing = await tx.query(
        "select id from message_threads where student_id = $1 and teacher_id = $2 and guardian_id = $3",
        [b.student_id, teacherId, guardianId]
      );
      if (existing.rows[0]) return { thread: await threadById(tx, existing.rows[0].id), created: false };
      let id;
      try {
        const ins = await tx.attempt(
          () => tx.query(
            `insert into message_threads (school_id, student_id, teacher_id, guardian_id)
             values (app.school_id(), $1, $2, $3) returning id`,
            [b.student_id, teacherId, guardianId]
          )
        );
        id = ins.rows[0].id;
      } catch (err) {
        const code = err.code;
        if (code === "42501" || code === "23503" || code === "23514")
          throw new AppError(403, "not_a_shared_child", "You can only message about a child you share with that person");
        throw err;
      }
      return { thread: await threadById(tx, id), created: true };
    });
    return c.json(thread, created ? 201 : 200);
  });
  r.get("/threads/:id/messages", async (c) => {
    const id = idParam(c);
    const q = query(c, pageQuery);
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        await threadById(tx, id);
        const params = [id, q.limit + 1];
        let cursorSql = "";
        if (cur) {
          params.push(cur.t, cur.id);
          cursorSql = `and (created_at, id) > ($3::timestamptz, $4::uuid)`;
        }
        const rows = await tx.query(
          `select id, thread_id, sender_id, body, created_at from messages
            where thread_id = $1 ${cursorSql} order by created_at, id limit $2`,
          params
        );
        const page = paginate(rows.rows, q.limit, (m) => m.created_at.toISOString());
        return {
          items: page.items.map((m) => ({ ...m, created_at: m.created_at.toISOString() })),
          next_cursor: page.next_cursor
        };
      })
    );
  });
  r.post("/threads/:id/messages", async (c) => {
    const id = idParam(c);
    const b = await body(c, z14.object({ body: z14.string().trim().min(1).max(5e3) }));
    const out = await asCaller(deps2, c, async (tx, me) => {
      await threadById(tx, id);
      try {
        const m = await tx.attempt(
          () => tx.query(
            `insert into messages (school_id, thread_id, sender_id, body, created_at) values (app.school_id(), $1, $2, $3, $4)
             returning id, thread_id, sender_id, body, created_at`,
            [id, me.personId, b.body, deps2.clock.now()]
          )
        );
        const row = m.rows[0];
        await tx.query(
          `insert into thread_reads (thread_id, person_id, last_read_at) values ($1, $2, $3)
           on conflict (thread_id, person_id) do update set last_read_at = excluded.last_read_at`,
          [id, me.personId, row.created_at]
        );
        return { ...row, created_at: row.created_at.toISOString() };
      } catch (err) {
        if (err.code === "42501") throw forbidden("Only the two people in this conversation can send messages", "not_a_participant");
        throw err;
      }
    });
    return c.json(out, 201);
  });
  r.post("/threads/:id/read", async (c) => {
    const id = idParam(c);
    await asCaller(deps2, c, async (tx, me) => {
      await threadById(tx, id);
      if (me.role === "admin") return;
      await tx.query(
        `insert into thread_reads (thread_id, person_id, last_read_at) values ($1, $2, $3)
         on conflict (thread_id, person_id) do update set last_read_at = excluded.last_read_at`,
        [id, me.personId, deps2.clock.now()]
      );
    });
    return c.body(null, 204);
  });
  return r;
}

// src/modules/onboarding/routes.ts
import { Hono as Hono14 } from "hono";
import { z as z15 } from "zod";
function onboardingRoutes(deps2) {
  const r = new Hono14();
  const auth = createAuthService(deps2);
  const limited = rateLimit({ bucket: "onboard", limit: deps2.config.AUTH_RATE_LIMIT_PER_MINUTE, windowMs: 6e4, now: deps2.clock.now });
  r.post("/schools", limited, async (c) => {
    const b = await body(
      c,
      z15.object({
        invite_code: z15.string().min(1).max(200),
        school_name: z15.string().trim().min(1).max(200),
        timezone: z15.string().trim().min(1).max(64).default("Africa/Accra"),
        admin: z15.object({
          full_name: z15.string().trim().min(1).max(120),
          email: z15.email().optional(),
          phone: z15.string().min(6).max(25).optional()
        }).refine((a) => a.email || a.phone, { message: "email or phone is required", path: ["email"] })
      })
    );
    const phone = b.admin.phone ? normalizePhone(b.admin.phone, deps2.config.DEFAULT_COUNTRY_CODE) : null;
    const email = b.admin.email ? b.admin.email.toLowerCase() : null;
    const codeHash = hashToken(b.invite_code);
    const now = deps2.clock.now();
    const { school, adminId } = await deps2.db.asService(async (tx) => {
      const invite = await tx.query(
        `select id from school_invites where code_hash = $1 and used_at is null and expires_at > $2 for update`,
        [codeHash, now]
      );
      const inviteId = invite.rows[0]?.id;
      if (!inviteId) throw badRequest("This invite code is invalid, used, or expired", "invalid_invite_code");
      const s = await tx.query(
        `insert into schools (name, timezone) values ($1, $2) returning id, name, timezone`,
        [b.school_name, b.timezone]
      );
      const school2 = s.rows[0];
      const p = await tx.query(
        `insert into people (school_id, full_name, role) values ($1, $2, 'admin') returning id`,
        [school2.id, b.admin.full_name]
      );
      const adminId2 = p.rows[0].id;
      if (phone || email) {
        await tx.query("insert into person_contacts (person_id, school_id, phone, email) values ($1, $2, $3, $4)", [
          adminId2,
          school2.id,
          phone,
          email
        ]);
      }
      await tx.query("update school_invites set used_at = $2, used_by_school_id = $3 where id = $1", [inviteId, now, school2.id]);
      return { school: school2, adminId: adminId2 };
    });
    await auth.inviteAccount(adminId, { email, phone });
    const out = { id: school.id, name: school.name, timezone: school.timezone };
    return c.json(out, 201);
  });
  return r;
}

// src/modules/reportcomments/routes.ts
import { Hono as Hono15 } from "hono";
import { z as z16 } from "zod";
async function visibleSection3(tx, id) {
  const r = await tx.query(
    `select cs.id, t.closed as term_closed from class_sections cs join terms t on t.id = cs.term_id where cs.id = $1`,
    [id]
  );
  if (!r.rows[0]) throw notFound("Class section");
  return r.rows[0];
}
function reportCommentRoutes(deps2) {
  const r = new Hono15();
  const staff = requireRole("teacher", "admin");
  const teacher = requireRole("teacher");
  const parentOrAdmin = requireRole("admin", "guardian");
  r.get("/class_sections/:id/comments", staff, async (c) => {
    const id = idParam(c);
    const q = query(c, z16.object({ subject: z16.string().min(1).max(60) }));
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const section = await visibleSection3(tx, id);
        const students = await tx.query(
          `select p.id, p.full_name from enrollments e join people p on p.id = e.student_id
            where e.class_section_id = $1 and e.status = 'active' order by p.full_name`,
          [id]
        );
        const existing = await tx.query(
          `select student_id, body, updated_at from report_comments where class_section_id = $1 and subject = $2`,
          [id, q.subject]
        );
        const byStudent = new Map(existing.rows.map((x) => [x.student_id, x]));
        return {
          class_section_id: id,
          subject: q.subject,
          term_closed: section.term_closed,
          items: students.rows.map((s) => ({
            student: studentRef(s),
            body: byStudent.get(s.id)?.body ?? null,
            updated_at: byStudent.get(s.id)?.updated_at.toISOString() ?? null
          }))
        };
      })
    );
  });
  r.patch("/class_sections/:id/comments", teacher, async (c) => {
    const id = idParam(c);
    const b = await body(
      c,
      z16.object({
        subject: z16.string().min(1).max(60),
        comments: z16.array(z16.object({ student_id: uuid, body: z16.string().max(2e3) })).min(1).max(200)
      })
    );
    return c.json(
      await asCaller(deps2, c, async (tx, me) => {
        const results = [];
        let applied = 0;
        let rejected = 0;
        for (const x of b.comments) {
          try {
            await tx.attempt(
              () => tx.query(
                `insert into report_comments (school_id, student_id, class_section_id, subject, teacher_id, body)
                 values (app.school_id(), $1, $2, $3, $4, $5)
                 on conflict (student_id, class_section_id, subject) do update
                   set body = excluded.body, updated_at = $6, teacher_id = $4`,
                [x.student_id, id, b.subject, me.personId, x.body, deps2.clock.now()]
              )
            );
            applied++;
            results.push({ student_id: x.student_id, outcome: "applied" });
          } catch (err) {
            const code = err.code;
            if (!["42501", "23514", "23503"].includes(code ?? "")) throw err;
            rejected++;
            results.push({
              student_id: x.student_id,
              outcome: "rejected",
              code: code === "42501" ? "not_enrolled" : "unknown_student",
              message: code === "42501" ? "This student is not enrolled in the section, or the term is closed" : "No such student"
            });
          }
        }
        return { applied, rejected, results };
      })
    );
  });
  r.get("/students/:id/report_comments", parentOrAdmin, async (c) => {
    const id = idParam(c);
    return c.json({
      items: await asCaller(deps2, c, async (tx) => {
        await visibleStudent(tx, id, "student_report_comments");
        const rows = await tx.query(
          `select rc.class_section_id, rc.subject, rc.body, rc.updated_at, rc.teacher_id, p.full_name as teacher_name
             from report_comments rc join people p on p.id = rc.teacher_id
            where rc.student_id = $1 order by rc.subject`,
          [id]
        );
        return rows.rows.map((x) => ({
          class_section_id: x.class_section_id,
          subject: x.subject,
          body: x.body,
          updated_at: x.updated_at.toISOString(),
          teacher: personRef({ id: x.teacher_id, full_name: x.teacher_name, role: "teacher" })
        }));
      })
    });
  });
  return r;
}

// src/modules/students/routes.ts
import { Hono as Hono16 } from "hono";
import { z as z17 } from "zod";
var RATE = `(select round(100.0 * count(*) filter (where a.status in ('present', 'late')) / nullif(count(*), 0), 1)
                 from attendance_records a where a.student_id = p.id)`;
var GUARDIAN_NAMES = `case when app.role() = 'admin' then (
  select coalesce(array_agg(g.full_name order by gs.is_primary_contact desc, g.full_name), '{}')
    from guardian_student gs join people g on g.id = gs.guardian_id where gs.student_id = p.id) end`;
var SECTION = `left join lateral (
    select cs.id, cs.name, cs.grade_level from enrollments e
    join class_sections cs on cs.id = e.class_section_id
    where e.student_id = p.id and e.status = 'active' order by cs.name limit 1) cs on true`;
function studentRoutes(deps2) {
  const r = new Hono16();
  r.get("/students", async (c) => {
    const q = query(
      c,
      pageQuery.extend({ q: z17.string().max(100).optional(), class_section_id: uuid.optional(), grade_level: z17.string().max(20).optional() })
    );
    const cur = decodeCursor(q.cursor);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        const params = [q.limit + 1];
        const where = [`p.role = 'student'`];
        const add = (sql, v) => {
          params.push(v);
          where.push(sql.replace("?", `$${params.length}`));
        };
        if (q.q) add("strpos(lower(p.full_name), lower(?)) > 0", q.q);
        if (q.class_section_id)
          add(`exists (select 1 from enrollments e where e.student_id = p.id and e.class_section_id = ? and e.status = 'active')`, q.class_section_id);
        if (q.grade_level)
          add(`exists (select 1 from enrollments e join class_sections s on s.id = e.class_section_id
                        where e.student_id = p.id and e.status = 'active' and s.grade_level = ?)`, q.grade_level);
        if (cur) {
          params.push(cur.t, cur.id);
          where.push(`(p.full_name, p.id) > ($${params.length - 1}, $${params.length}::uuid)`);
        }
        const rows = await tx.query(
          `select p.id, p.full_name, cs.id as section_id, cs.name as section_name, cs.grade_level, ${RATE} as rate, ${GUARDIAN_NAMES} as gnames
             from people p ${SECTION}
            where ${where.join(" and ")}
            order by p.full_name, p.id limit $1`,
          params
        );
        const page = paginate(rows.rows, q.limit, (s) => s.full_name);
        return {
          items: page.items.map((s) => ({
            ...studentRef(s),
            ...s.grade_level ? { grade_level: s.grade_level } : {},
            attendance_rate_pct: num(s.rate),
            ...s.gnames ? { guardian_names: s.gnames } : {}
          })),
          next_cursor: page.next_cursor
        };
      })
    );
  });
  r.get("/students/:id", async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps2, c, async (tx, me) => {
        await visibleStudent(tx, id, "student_detail");
        const s = await tx.query(
          `select p.id, p.full_name, cs.id as section_id, cs.name as section_name, cs.grade_level, ${RATE} as rate
             from people p ${SECTION} where p.id = $1`,
          [id]
        );
        const row = s.rows[0];
        const out = {
          ...studentRef(row),
          ...row.grade_level ? { grade_level: row.grade_level } : {},
          attendance_rate_pct: num(row.rate)
        };
        if (me.role === "admin" || me.role === "teacher") {
          const g = await tx.query(
            `select g.id, g.full_name, g.role, gs.relationship, gs.is_primary_contact, pc.phone, pc.email
               from guardian_student gs join people g on g.id = gs.guardian_id
               left join person_contacts pc on pc.person_id = g.id
              where gs.student_id = $1 order by gs.is_primary_contact desc, g.full_name`,
            [id]
          );
          out.guardians = g.rows.map((x) => ({
            guardian: {
              id: x.id,
              full_name: x.full_name,
              role: x.role,
              ...me.role === "admin" && (x.phone || x.email) ? { contact: { ...x.phone ? { phone: x.phone } : {}, ...x.email ? { email: x.email } : {} } } : {}
            },
            relationship: x.relationship,
            is_primary_contact: x.is_primary_contact
          }));
        }
        if (me.role === "admin") {
          const e = await tx.query(
            `select e.id, e.student_id, e.class_section_id, cs.name as class_section_name, t.name as term_name, e.status
               from enrollments e join class_sections cs on cs.id = e.class_section_id join terms t on t.id = cs.term_id
              where e.student_id = $1 order by t.starts_on desc, cs.name`,
            [id]
          );
          out.enrollments = e.rows;
        }
        return out;
      })
    );
  });
  r.get("/students/:id/summary", async (c) => {
    const id = idParam(c);
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        try {
          const out = await tx.query(
            "select student_summary($1) as s",
            [id]
          );
          const fn = out.rows[0].s;
          return {
            ...fn,
            balance: fn.balance == null ? null : money(fn.balance),
            pending_payments: fn.pending_payments == null ? null : money(fn.pending_payments)
          };
        } catch (err) {
          if (err.code === "42501") throw notFound("Student");
          throw err;
        }
      })
    );
  });
  r.get("/students/:id/attendance", async (c) => {
    const id = idParam(c);
    const q = query(c, z17.object({ from: isoDate.optional(), to: isoDate.optional() }));
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        await visibleStudent(tx, id, "student_attendance");
        const rows = await tx.query(
          `select id, student_id, class_section_id, period_id, period_date, status, note, marked_by, marked_at
             from attendance_records
            where student_id = $1 and ($2::date is null or period_date >= $2) and ($3::date is null or period_date <= $3)
            order by period_date desc, marked_at desc`,
          [id, q.from ?? null, q.to ?? null]
        );
        const items = rows.rows.map((a) => ({
          ...a,
          marked_at: a.marked_at.toISOString(),
          ...a.note ? { note: a.note } : { note: null },
          period_id: a.period_id
        }));
        return { items };
      })
    );
  });
  r.get("/students/:id/grades", async (c) => {
    const id = idParam(c);
    const q = query(c, z17.object({ term_id: uuid.optional() }));
    return c.json(
      await asCaller(deps2, c, async (tx) => {
        await visibleStudent(tx, id, "student_grades");
        const rows = await tx.query(
          `select a.class_section_id, a.subject, a.id, a.title, a.weight, a.max_score, a.due_date, g.score, g.comment
             from assessments a
             join class_sections cs on cs.id = a.class_section_id
             join terms t on t.id = cs.term_id
             join enrollments e on e.class_section_id = a.class_section_id and e.student_id = $1
             left join grades g on g.assessment_id = a.id and g.student_id = $1
            where ($2::uuid is null and not t.closed) or cs.term_id = $2
            order by a.class_section_id, a.subject, a.due_date nulls last, a.title`,
          [id, q.term_id ?? null]
        );
        const groups = /* @__PURE__ */ new Map();
        const numeric = /* @__PURE__ */ new Map();
        for (const x of rows.rows) {
          const key = `${x.class_section_id}|${x.subject}`;
          if (!groups.has(key)) groups.set(key, { class_section_id: x.class_section_id, subject: x.subject, running_grade: null, grade_band: null, assessments: [] });
          const item = { score: num(x.score), max_score: Number(x.max_score), weight: Number(x.weight) };
          numeric.set(key, [...numeric.get(key) ?? [], item]);
          groups.get(key).assessments.push({
            id: x.id,
            subject: x.subject,
            title: x.title,
            weight: item.weight,
            max_score: item.max_score,
            due_date: x.due_date,
            score: item.score,
            comment: x.comment
          });
        }
        const bandRows = await tx.query(
          "select label, min_score, max_score from grade_bands"
        );
        const bands = bandRows.rows.map((b) => ({ label: b.label, min_score: Number(b.min_score), max_score: Number(b.max_score) }));
        for (const [key, g] of groups) {
          g.running_grade = runningGrade(numeric.get(key));
          g.grade_band = gradeBandFor(g.running_grade, bands);
        }
        return { subjects: [...groups.values()] };
      })
    );
  });
  return r;
}

// src/app.ts
function createApp(deps2) {
  const app2 = new Hono17();
  const origins = deps2.config.CORS_ORIGINS === "*" ? "*" : deps2.config.CORS_ORIGINS.split(",").map((s) => s.trim());
  app2.use("*", requestContext(deps2));
  app2.use(
    "*",
    cors({
      origin: origins,
      allowHeaders: ["authorization", "content-type", "idempotency-key", "x-request-id"],
      exposeHeaders: ["x-request-id", "retry-after", "idempotent-replay"],
      maxAge: 600
    })
  );
  app2.use(
    "*",
    bodyLimit({
      maxSize: 1e6,
      onError: () => {
        throw new AppError(413, "payload_too_large", "Request body is too large");
      }
    })
  );
  app2.onError(errorHandler());
  app2.notFound(() => {
    throw new AppError(404, "not_found", "No such endpoint");
  });
  app2.get("/healthz", (c) => c.json({ status: "ok" }));
  app2.get("/readyz", async (c) => {
    try {
      await deps2.db.ping();
      const current = await migrationsCurrent(deps2.db);
      return c.json({ status: current ? "ready" : "migrations_pending" }, current ? 200 : 503);
    } catch (err) {
      c.var.log.error("readiness check failed", { err });
      return c.json({ status: "database_unreachable" }, 503);
    }
  });
  const v1 = new Hono17();
  v1.route("/auth", authRoutes(deps2));
  v1.route("/", onboardingRoutes(deps2));
  v1.route("/webhooks", webhookRoutes(deps2));
  const dev = devRoutes(deps2);
  if (dev) v1.route("/dev", dev);
  const authed = new Hono17();
  authed.use("*", authenticate(deps2));
  authed.use("*", idempotency(deps2));
  for (const routes of [
    meRoutes,
    studentRoutes,
    classRoutes,
    attendanceRoutes,
    gradebookRoutes,
    gradingRoutes,
    reportCommentRoutes,
    feesRoutes,
    messagingRoutes,
    announcementRoutes,
    homeworkRoutes,
    conferenceRoutes,
    adminRoutes
  ]) {
    authed.route("/", routes(deps2));
  }
  v1.route("/", authed);
  app2.route("/v1", v1);
  return app2;
}

// src/db/pglite.ts
import { mkdirSync } from "node:fs";
import { PGlite } from "@electric-sql/pglite";

// src/db/types.ts
function withSavepoints(raw) {
  let depth = 0;
  return {
    query: (sql, params) => raw.query(sql, params),
    exec: (sql) => raw.exec(sql),
    async attempt(fn) {
      const name = `sp_${++depth}`;
      await raw.exec(`savepoint ${name}`);
      try {
        const out = await fn();
        await raw.exec(`release savepoint ${name}`);
        return out;
      } catch (err) {
        await raw.exec(`rollback to savepoint ${name}`);
        await raw.exec(`release savepoint ${name}`);
        throw err;
      }
    }
  };
}
var OID_DATE = 1082;

// src/db/pglite.ts
function adapt(t) {
  return {
    async query(sql, params = []) {
      const r = await t.query(sql, [...params]);
      return { rows: r.rows, rowCount: r.rows.length > 0 ? r.rows.length : r.affectedRows ?? 0 };
    },
    async exec(sql) {
      await t.exec(sql);
    }
  };
}
async function openPglite(opts = {}) {
  if (opts.dataDir) mkdirSync(opts.dataDir, { recursive: true });
  const pg2 = new PGlite({
    ...opts.dataDir ? { dataDir: opts.dataDir } : {},
    parsers: { [OID_DATE]: (v) => v }
  });
  await pg2.waitReady;
  const run = (fn, prelude) => pg2.transaction(async (t) => {
    const raw = adapt(t);
    if (prelude) await prelude(raw);
    return fn(withSavepoints(raw));
  });
  return {
    asService: (fn) => run(fn),
    asUser: (personId, fn) => run(fn, async (raw) => {
      await raw.exec("set local role app_user");
      await raw.query(`select set_config('app.person_id', $1, true)`, [personId]);
    }),
    async ping() {
      await pg2.query("select 1");
    },
    async close() {
      await pg2.close();
    }
  };
}

// src/db/postgres.ts
import pg from "pg";
function adapt2(client) {
  return {
    async query(sql, params = []) {
      const r = await client.query(sql, [...params]);
      return { rows: r.rows, rowCount: r.rowCount ?? r.rows.length };
    },
    async exec(sql) {
      await client.query(sql);
    }
  };
}
function openPostgres(connectionString, opts = {}) {
  const pool = new pg.Pool({
    connectionString,
    max: opts.max ?? 10,
    types: {
      getTypeParser: ((oid, format) => oid === OID_DATE ? (v) => v : pg.types.getTypeParser(oid, format))
    }
  });
  async function run(fn, prelude) {
    const client = await pool.connect();
    const raw = adapt2(client);
    try {
      await client.query("begin");
      if (prelude) await prelude(raw);
      const out = await fn(withSavepoints(raw));
      await client.query("commit");
      return out;
    } catch (err) {
      await client.query("rollback").catch(() => void 0);
      throw err;
    } finally {
      client.release();
    }
  }
  return {
    asService: (fn) => run(fn),
    asUser: (personId, fn) => run(fn, async (raw) => {
      await raw.exec("set local role app_user");
      await raw.query(`select set_config('app.person_id', $1, true)`, [personId]);
    }),
    async ping() {
      await pool.query("select 1");
    },
    async close() {
      await pool.end();
    }
  };
}

// src/integrations/channels.ts
function consoleSms(log) {
  const sent = [];
  return {
    sent,
    clear: () => void (sent.length = 0),
    async send(to, text) {
      sent.push({ to, text });
      log.info("sms (console)", { to, text });
    }
  };
}
function consolePush(log) {
  const sent = [];
  return {
    sent,
    clear: () => void (sent.length = 0),
    async send(targets, message) {
      sent.push({ targets, message });
      log.info("push (console)", { tokens: targets.length, title: message.title });
      return { invalidTokens: [] };
    }
  };
}
function consoleEmail(log) {
  const sent = [];
  return {
    sent,
    clear: () => void (sent.length = 0),
    async send(to, subject, text) {
      sent.push({ to, subject, text });
      log.info("email (console)", { to, subject });
    }
  };
}

// src/integrations/paystack.ts
var API = "https://api.paystack.co";
var MOMO_BANK_TO_METHOD = {
  mtn: "mtn_momo",
  MTN: "mtn_momo",
  vod: "telecel_cash",
  VOD: "telecel_cash",
  vodafone: "telecel_cash",
  telecel: "telecel_cash"
};
var PaystackGateway = class {
  name = "paystack";
  #secretKey;
  #webUrl;
  constructor(secretKey, webUrl) {
    this.#secretKey = secretKey;
    this.#webUrl = webUrl;
  }
  async initiate(input) {
    if (input.method === "card") {
      const res2 = await fetch(`${API}/transaction/initialize`, {
        method: "POST",
        headers: { authorization: `Bearer ${this.#secretKey}`, "content-type": "application/json" },
        body: JSON.stringify({
          reference: input.reference,
          amount: Math.round(Number(input.amount) * 100),
          // GHS -> pesewas
          currency: input.currency,
          email: input.email ?? `${input.reference}@invoice.homeroom.app`,
          // Paystack requires an email even for card
          callback_url: input.callbackUrl,
          metadata: input.metadata
        })
      });
      const body3 = await res2.json();
      if (!res2.ok || !body3.status || !body3.data) throw new Error(`Paystack initialize failed: ${body3.message ?? res2.status}`);
      return { type: "redirect", redirectUrl: body3.data.authorization_url };
    }
    const provider = input.method === "mtn_momo" ? "mtn" : "vod";
    const res = await fetch(`${API}/charge`, {
      method: "POST",
      headers: { authorization: `Bearer ${this.#secretKey}`, "content-type": "application/json" },
      body: JSON.stringify({
        reference: input.reference,
        amount: Math.round(Number(input.amount) * 100),
        currency: input.currency,
        email: input.email ?? `${input.reference}@invoice.homeroom.app`,
        mobile_money: { phone: input.phone, provider },
        metadata: input.metadata
      })
    });
    const body2 = await res.json();
    if (!res.ok || !body2.status) throw new Error(`Paystack charge failed: ${body2.message ?? res.status}`);
    return { type: "prompt", message: body2.data?.display_text ?? `Approve the request on ${input.phone ?? "your phone"}` };
  }
  /** Paystack signs the raw body with HMAC-SHA512 of the secret key, in `x-paystack-signature`. */
  verifyWebhook(rawBody, headers) {
    const sig = headers.get("x-paystack-signature");
    return !!sig && safeEqualHex(sig, hmacHex("sha512", this.#secretKey, rawBody));
  }
  parseWebhook(rawBody) {
    const e = JSON.parse(rawBody);
    const status2 = e.event === "charge.success" ? "succeeded" : e.event === "charge.failed" ? "failed" : null;
    const d = e.data;
    if (!status2 || !d?.reference || d.amount == null) return null;
    const metadata = typeof d.metadata === "object" ? d.metadata : void 0;
    const invoiceId = metadata?.invoice_id;
    if (!invoiceId) return null;
    const method = d.channel === "mobile_money" ? MOMO_BANK_TO_METHOD[d.authorization?.bank ?? ""] ?? "mtn_momo" : "card";
    return {
      providerRef: d.reference,
      status: status2,
      amount: (d.amount / 100).toFixed(2),
      // pesewas -> GHS
      method,
      invoiceId
    };
  }
};

// src/integrations/push.ts
import { SignJWT as SignJWT2, importPKCS8 } from "jose";
var FcmPush = class {
  #creds;
  #log;
  #cached = null;
  constructor(creds, log) {
    this.#creds = creds;
    this.#log = log;
  }
  async #accessToken() {
    const now = Date.now();
    if (this.#cached && this.#cached.expiresAt > now + 6e4) return this.#cached.token;
    const key = await importPKCS8(this.#creds.privateKey, "RS256");
    const assertion = await new SignJWT2({ scope: "https://www.googleapis.com/auth/firebase.messaging" }).setProtectedHeader({ alg: "RS256" }).setIssuer(this.#creds.clientEmail).setSubject(this.#creds.clientEmail).setAudience("https://oauth2.googleapis.com/token").setIssuedAt().setExpirationTime("1h").sign(key);
    const res = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "content-type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({ grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion })
    });
    const body2 = await res.json();
    if (!res.ok || !body2.access_token) throw new Error(`FCM token exchange failed: ${body2.error ?? res.status}`);
    this.#cached = { token: body2.access_token, expiresAt: now + (body2.expires_in ?? 3600) * 1e3 };
    return body2.access_token;
  }
  async send(targets, message) {
    if (targets.length === 0) return { invalidTokens: [] };
    const accessToken = await this.#accessToken();
    const invalidTokens = [];
    await Promise.all(
      targets.map(async (t) => {
        const res = await fetch(`https://fcm.googleapis.com/v1/projects/${this.#creds.projectId}/messages:send`, {
          method: "POST",
          headers: { authorization: `Bearer ${accessToken}`, "content-type": "application/json" },
          body: JSON.stringify({ message: { token: t.token, notification: { title: message.title, body: message.body }, data: message.data ?? {} } })
        });
        if (!res.ok) {
          const err = await res.json().catch(() => null);
          if (err?.error?.status === "UNREGISTERED" || err?.error?.status === "NOT_FOUND") invalidTokens.push(t.token);
          else this.#log.error("fcm send failed", { status: res.status, platform: t.platform, error: err?.error });
        }
      })
    );
    return { invalidTokens };
  }
};

// src/integrations/sms.ts
var TwilioSms = class {
  #accountSid;
  #authToken;
  #from;
  #log;
  constructor(opts, log) {
    this.#accountSid = opts.accountSid;
    this.#authToken = opts.authToken;
    this.#from = opts.from;
    this.#log = log;
  }
  async send(to, text) {
    const auth = Buffer.from(`${this.#accountSid}:${this.#authToken}`).toString("base64");
    const res = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${this.#accountSid}/Messages.json`, {
      method: "POST",
      headers: { authorization: `Basic ${auth}`, "content-type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({ To: to, From: this.#from, Body: text })
    });
    if (!res.ok) {
      const detail = await res.text().catch(() => "");
      this.#log.error("twilio sms failed", { status: res.status, to, detail: detail.slice(0, 500) });
      throw new Error(`Twilio SMS failed with status ${res.status}`);
    }
  }
};
var HubtelSms = class {
  #clientId;
  #clientSecret;
  #from;
  #log;
  constructor(opts, log) {
    this.#clientId = opts.clientId;
    this.#clientSecret = opts.clientSecret;
    this.#from = opts.from;
    this.#log = log;
  }
  async send(to, text) {
    const url = new URL("https://sms.hubtel.com/v1/messages/send");
    url.searchParams.set("clientid", this.#clientId);
    url.searchParams.set("clientsecret", this.#clientSecret);
    url.searchParams.set("from", this.#from);
    url.searchParams.set("to", to);
    url.searchParams.set("content", text);
    const res = await fetch(url, { method: "GET" });
    if (!res.ok) {
      const detail = await res.text().catch(() => "");
      this.#log.error("hubtel sms failed", { status: res.status, to, detail: detail.slice(0, 500) });
      throw new Error(`Hubtel SMS failed with status ${res.status}`);
    }
  }
};

// src/lib/clock.ts
var systemClock = { now: () => /* @__PURE__ */ new Date() };
function fixedClock(iso2) {
  let t = new Date(iso2).getTime();
  return {
    now: () => new Date(t),
    set: (next) => {
      t = new Date(next).getTime();
    },
    advance: (ms) => {
      t += ms;
    }
  };
}

// src/lib/logger.ts
var LEVELS = { debug: 10, info: 20, warn: 30, error: 40 };
function createLogger(opts = {}) {
  const min = LEVELS[opts.level ?? "info"];
  const sink = opts.sink ?? ((line) => process.stdout.write(line + "\n"));
  const bindings = opts.bindings ?? {};
  const emit = (level, msg, fields) => {
    if (LEVELS[level] < min) return;
    sink(JSON.stringify({ t: (/* @__PURE__ */ new Date()).toISOString(), level, msg, ...bindings, ...fields }, errorReplacer));
  };
  return {
    debug: (m, f) => emit("debug", m, f),
    info: (m, f) => emit("info", m, f),
    warn: (m, f) => emit("warn", m, f),
    error: (m, f) => emit("error", m, f),
    child: (b) => createLogger({ level: opts.level ?? "info", sink, bindings: { ...bindings, ...b } })
  };
}
function errorReplacer(_key, value) {
  if (value instanceof Error) {
    const e = value;
    return { name: e.name, message: e.message, code: e.code, stack: e.stack };
  }
  return value;
}
var silentLogger = createLogger({ level: "error", sink: () => void 0 });

// src/bootstrap.ts
function buildSms(config2, log) {
  if (config2.SMS_PROVIDER === "twilio") {
    return new TwilioSms({ accountSid: config2.TWILIO_ACCOUNT_SID, authToken: config2.TWILIO_AUTH_TOKEN, from: config2.TWILIO_FROM }, log);
  }
  if (config2.SMS_PROVIDER === "hubtel") {
    return new HubtelSms({ clientId: config2.HUBTEL_CLIENT_ID, clientSecret: config2.HUBTEL_CLIENT_SECRET, from: config2.HUBTEL_FROM }, log);
  }
  return consoleSms(log);
}
function buildPush(config2, log) {
  if (config2.PUSH_PROVIDER === "fcm") {
    return new FcmPush(
      { projectId: config2.FCM_PROJECT_ID, clientEmail: config2.FCM_CLIENT_EMAIL, privateKey: config2.FCM_PRIVATE_KEY.replace(/\\n/g, "\n") },
      log
    );
  }
  return consolePush(log);
}
function buildPaymentGateway(config2) {
  return config2.PAYMENT_GATEWAY === "paystack" ? new PaystackGateway(config2.PAYSTACK_SECRET_KEY, config2.PUBLIC_WEB_URL) : new SandboxGateway(config2.PAYMENT_WEBHOOK_SECRET, config2.PUBLIC_WEB_URL);
}
async function openDb(config2, log) {
  if (config2.DATABASE_URL) {
    log.info("database: postgres");
    return openPostgres(config2.DATABASE_URL);
  }
  const dir = config2.NODE_ENV === "test" ? "" : config2.PGLITE_DIR;
  log.info("database: embedded pglite", { dataDir: dir || "(memory)" });
  return openPglite(dir ? { dataDir: dir } : {});
}
async function createDeps(config2, overrides = {}) {
  const log = overrides.log ?? createLogger({ level: config2.LOG_LEVEL });
  const db = overrides.db ?? await openDb(config2, log);
  const clock = overrides.clock ?? (config2.DEMO_NOW && config2.NODE_ENV !== "production" ? fixedClock(config2.DEMO_NOW) : systemClock);
  if (config2.DEMO_NOW && config2.NODE_ENV === "production") log.warn("DEMO_NOW is ignored in production");
  const migrated = await migrate(db);
  if (migrated.applied.length) log.info("migrations applied", { migrations: migrated.applied });
  return {
    config: config2,
    db,
    log,
    clock,
    tokens: overrides.tokens ?? createTokenService(config2.JWT_SECRET, clock.now),
    sms: overrides.sms ?? buildSms(config2, log),
    push: overrides.push ?? buildPush(config2, log),
    email: overrides.email ?? consoleEmail(log),
    payments: overrides.payments ?? buildPaymentGateway(config2)
  };
}

// src/config.ts
import { z as z18 } from "zod";
var schema = z18.object({
  NODE_ENV: z18.enum(["development", "test", "production"]).default("development"),
  PORT: z18.coerce.number().int().positive().default(3e3),
  LOG_LEVEL: z18.enum(["debug", "info", "warn", "error"]).default("info"),
  /** Postgres connection string. When unset, an embedded PGlite database is used. */
  DATABASE_URL: z18.string().optional(),
  /** Where PGlite persists data in development. Empty string = in-memory. */
  PGLITE_DIR: z18.string().default(".data/pglite"),
  JWT_SECRET: z18.string().min(32).optional(),
  ACCESS_TOKEN_TTL_SECONDS: z18.coerce.number().int().positive().default(15 * 60),
  REFRESH_TOKEN_TTL_SECONDS: z18.coerce.number().int().positive().default(30 * 24 * 3600),
  /** Comma-separated origins allowed by CORS, or * in development. */
  CORS_ORIGINS: z18.string().default("*"),
  PAYMENT_GATEWAY: z18.enum(["sandbox", "paystack"]).default("sandbox"),
  PAYMENT_WEBHOOK_SECRET: z18.string().min(16).optional(),
  PAYSTACK_SECRET_KEY: z18.string().optional(),
  /** Explicit opt-in to run production with fake payments (MVP/evaluation deploys without a Paystack account yet). */
  ALLOW_SANDBOX_PAYMENTS: z18.enum(["true", "false"]).default("false").transform((v) => v === "true"),
  /** Base URL the gateway redirects the parent back to after checkout. */
  PUBLIC_WEB_URL: z18.string().url().default("http://localhost:5173"),
  /** Console just logs what would have been sent (default dev/test); a real provider is opt-in. */
  SMS_PROVIDER: z18.enum(["console", "twilio", "hubtel"]).default("console"),
  TWILIO_ACCOUNT_SID: z18.string().optional(),
  TWILIO_AUTH_TOKEN: z18.string().optional(),
  TWILIO_FROM: z18.string().optional(),
  HUBTEL_CLIENT_ID: z18.string().optional(),
  HUBTEL_CLIENT_SECRET: z18.string().optional(),
  HUBTEL_FROM: z18.string().optional(),
  PUSH_PROVIDER: z18.enum(["console", "fcm"]).default("console"),
  FCM_PROJECT_ID: z18.string().optional(),
  FCM_CLIENT_EMAIL: z18.string().optional(),
  /** PEM private key from the Firebase service account JSON; literal `\n` is unescaped before use. */
  FCM_PRIVATE_KEY: z18.string().optional(),
  /** Seed the demo school on first boot of an empty database (development only). */
  SEED_DEMO: z18.enum(["true", "false"]).default("false").transform((v) => v === "true"),
  DEMO_PASSWORD: z18.string().default("password123"),
  /**
   * Development only: pretend "now" is this instant, so the demo school's dates (Term 1 2026, marks for
   * 28 Sep to 2 Oct) line up with what the screens show. Ignored in production.
   */
  DEMO_NOW: z18.iso.datetime().optional(),
  /** Prepended to phone numbers entered without a country code (a leading 0 is dropped). */
  DEFAULT_COUNTRY_CODE: z18.string().regex(/^\+\d{1,3}$/).default("+233"),
  /** Max sign-in style requests per client per minute (0 disables). */
  AUTH_RATE_LIMIT_PER_MINUTE: z18.coerce.number().int().min(0).default(20)
});
var DEV_JWT_SECRET = "dev-only-secret-do-not-use-in-production-0000";
var DEV_WEBHOOK_SECRET = "dev-only-webhook-secret";
function loadConfig(env = process.env) {
  const parsed = schema.safeParse(env);
  if (!parsed.success) {
    const lines = parsed.error.issues.map((i) => `  ${i.path.join(".")}: ${i.message}`);
    throw new Error(`Invalid configuration:
${lines.join("\n")}`);
  }
  const c = parsed.data;
  if (c.SMS_PROVIDER === "twilio" && !(c.TWILIO_ACCOUNT_SID && c.TWILIO_AUTH_TOKEN && c.TWILIO_FROM)) {
    throw new Error("SMS_PROVIDER=twilio needs TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN and TWILIO_FROM");
  }
  if (c.SMS_PROVIDER === "hubtel" && !(c.HUBTEL_CLIENT_ID && c.HUBTEL_CLIENT_SECRET && c.HUBTEL_FROM)) {
    throw new Error("SMS_PROVIDER=hubtel needs HUBTEL_CLIENT_ID, HUBTEL_CLIENT_SECRET and HUBTEL_FROM");
  }
  if (c.PUSH_PROVIDER === "fcm" && !(c.FCM_PROJECT_ID && c.FCM_CLIENT_EMAIL && c.FCM_PRIVATE_KEY)) {
    throw new Error("PUSH_PROVIDER=fcm needs FCM_PROJECT_ID, FCM_CLIENT_EMAIL and FCM_PRIVATE_KEY");
  }
  if (c.NODE_ENV === "production") {
    const missing = [
      !c.JWT_SECRET && "JWT_SECRET",
      !c.DATABASE_URL && "DATABASE_URL",
      !c.PAYMENT_WEBHOOK_SECRET && "PAYMENT_WEBHOOK_SECRET",
      c.PAYMENT_GATEWAY === "paystack" && !c.PAYSTACK_SECRET_KEY && "PAYSTACK_SECRET_KEY"
    ].filter(Boolean);
    if (missing.length) throw new Error(`Missing required production settings: ${missing.join(", ")}`);
    if (c.CORS_ORIGINS === "*") throw new Error("CORS_ORIGINS must list explicit origins in production");
    if (c.PAYMENT_GATEWAY === "sandbox" && !c.ALLOW_SANDBOX_PAYMENTS) {
      throw new Error(
        "PAYMENT_GATEWAY=sandbox is not allowed in production unless ALLOW_SANDBOX_PAYMENTS=true (MVP/evaluation only \u2014 no real money moves until PAYMENT_GATEWAY=paystack is configured)"
      );
    }
  }
  return {
    ...c,
    JWT_SECRET: c.JWT_SECRET ?? DEV_JWT_SECRET,
    PAYMENT_WEBHOOK_SECRET: c.PAYMENT_WEBHOOK_SECRET ?? DEV_WEBHOOK_SECRET
  };
}

// src/vercel.ts
var config = loadConfig();
var deps = await createDeps(config);
var app = createApp(deps);
var fetch2 = app.fetch;
export {
  fetch2 as fetch
};
