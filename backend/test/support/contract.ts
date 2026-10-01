import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import $RefParser from '@apidevtools/json-schema-ref-parser';
import { parse } from 'yaml';

/**
 * Contract conformance: every response a test receives is validated against the schema
 * in openapi.yaml for that operation and status. If a handler drifts from the contract
 * (a renamed field, a wrong type, a missing property) the test fails naming the field.
 */

const SPEC_PATH = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'openapi.yaml');

interface Operation {
  responses: Record<string, { content?: Record<string, { schema?: object }> } | undefined>;
}
interface Spec {
  paths: Record<string, Record<string, Operation | undefined>>;
}

let loaded: Promise<{ spec: Spec; ajv: Ajv }> | undefined;
function load() {
  loaded ??= (async () => {
    const raw = parse(readFileSync(SPEC_PATH, 'utf8'));
    const spec = (await $RefParser.dereference(raw)) as unknown as Spec;
    const ajv = new Ajv({ strict: false, allErrors: true });
    (addFormats as unknown as (a: Ajv) => void)(ajv);
    return { spec, ajv };
  })();
  return loaded;
}

function templateToRegex(template: string): RegExp {
  return new RegExp('^' + template.replace(/\{[^}]+\}/g, '[^/]+') + '$');
}

/** Find the OpenAPI operation for a concrete request path (e.g. /students/abc -> /students/{id}). */
function findOperation(spec: Spec, method: string, path: string): { template: string; op: Operation } | undefined {
  const clean = path.replace(/^\/v1/, '').split('?')[0]!;
  // Prefer exact template matches with fewer path parameters (so /threads/read-ish literals win).
  const candidates = Object.keys(spec.paths)
    .filter((t) => templateToRegex(t).test(clean))
    .sort((a, b) => (a.match(/\{/g)?.length ?? 0) - (b.match(/\{/g)?.length ?? 0));
  for (const template of candidates) {
    const op = spec.paths[template]?.[method.toLowerCase()];
    if (op) return { template, op };
  }
  return undefined;
}

export async function assertContract(method: string, path: string, status: number, body: unknown): Promise<void> {
  const { spec, ajv } = await load();
  const found = findOperation(spec, method, path);
  if (!found) throw new Error(`Contract: no operation for ${method} ${path}`);

  const responses = found.op.responses;
  const entry = responses[String(status)] ?? responses[`${Math.floor(status / 100)}XX`] ?? responses['default'];
  if (!entry) throw new Error(`Contract: ${method} ${found.template} does not declare a ${status} response`);

  const media = entry.content?.['application/json'] ?? entry.content?.['application/problem+json'];
  if (!media?.schema) {
    if (body !== null && body !== undefined && body !== '') {
      throw new Error(`Contract: ${method} ${found.template} ${status} declares no body but one was returned`);
    }
    return;
  }
  const validate = ajv.compile(media.schema);
  if (!validate(body)) {
    const why = (validate.errors ?? []).map((e) => `${e.instancePath || '(root)'} ${e.message}`).join('; ');
    throw new Error(`Contract violation: ${method} ${found.template} -> ${status}: ${why}\nbody: ${JSON.stringify(body).slice(0, 600)}`);
  }
}
