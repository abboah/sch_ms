import { ZodError } from 'zod';

/**
 * Every failure leaves the API as an RFC 9457 problem document with a stable `code`
 * clients can switch on. Handlers throw AppError; database and validation errors are
 * translated once, in `toProblem`, so the mapping is in one place.
 */

export interface ProblemBody {
  status: number;
  title: string;
  code: string;
  detail?: string;
  errors?: { field: string; message: string }[];
  request_id?: string;
}

export class AppError extends Error {
  readonly status: number;
  readonly code: string;
  readonly errors: { field: string; message: string }[] | undefined;
  constructor(status: number, code: string, message: string, errors?: { field: string; message: string }[]) {
    super(message);
    this.name = 'AppError';
    this.status = status;
    this.code = code;
    this.errors = errors;
  }
}

export const badRequest = (message: string, code = 'bad_request') => new AppError(400, code, message);
export const unauthorized = (message = 'Authentication required', code = 'unauthorized') =>
  new AppError(401, code, message);
export const forbidden = (message = 'You are not allowed to do that', code = 'forbidden') =>
  new AppError(403, code, message);
/** Also used for rows the caller may not see, so existence is never leaked. */
export const notFound = (what = 'Resource') => new AppError(404, 'not_found', `${what} not found`);
export const conflict = (message: string, code = 'conflict') => new AppError(409, code, message);
export const unprocessable = (message: string, code = 'unprocessable') => new AppError(422, code, message);
export const tooMany = (message = 'Too many requests, slow down') => new AppError(429, 'rate_limited', message);

interface PgLikeError {
  code?: string;
  message?: string;
  constraint?: string;
  detail?: string;
}

const STATUS_TITLES: Record<number, string> = {
  400: 'Bad request',
  401: 'Unauthorized',
  403: 'Forbidden',
  404: 'Not found',
  409: 'Conflict',
  422: 'Unprocessable',
  429: 'Too many requests',
  500: 'Internal server error',
};

const title = (status: number) => STATUS_TITLES[status] ?? 'Error';

/** Translate anything thrown into a problem document (never leaks internals on 500). */
export function toProblem(err: unknown, requestId?: string): ProblemBody {
  const base = (status: number, code: string, detail?: string, errors?: ProblemBody['errors']): ProblemBody => ({
    status,
    title: title(status),
    code,
    ...(detail ? { detail } : {}),
    ...(errors ? { errors } : {}),
    ...(requestId ? { request_id: requestId } : {}),
  });

  if (err instanceof AppError) return base(err.status, err.code, err.message, err.errors);

  if (err instanceof ZodError) {
    return base(
      400,
      'validation_failed',
      'The request did not match the expected shape',
      err.issues.map((i) => ({ field: i.path.join('.') || '(body)', message: i.message })),
    );
  }

  const e = err as PgLikeError;
  switch (e?.code) {
    case '42501': // insufficient_privilege, which is also what RLS raises on a denied write
      return base(403, 'forbidden', 'You are not allowed to do that');
    case 'HR409': // our own SQLSTATE for "already taken" raised by database functions
      return base(409, 'conflict', e.message ?? 'That is already taken');
    case '23505':
      return base(409, 'already_exists', 'That record already exists');
    case '23503':
      return base(409, 'invalid_reference', 'A referenced record does not exist or is not in your school');
    case '23514':
      return base(422, 'constraint_violated', e.message ?? 'A value is out of range');
    case '22P02': // invalid text representation (for example a malformed uuid)
    case '22007':
    case '22008':
      return base(400, 'invalid_value', 'A value is malformed');
    case '22003':
      return base(400, 'out_of_range', 'A numeric value is out of range');
  }
  return base(500, 'internal_error', 'Something went wrong on our side');
}
