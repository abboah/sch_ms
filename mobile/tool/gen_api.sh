#!/usr/bin/env bash
# Regenerate the typed Dart client from the API contract (backend/openapi.yaml).
# Needs Java 11+ and Node (for npx). Run from anywhere:  mobile/tool/gen_api.sh
#
# Calendar dates ("2026-10-05") must stay strings: the generator's DateTime mapping introduces timezone shifts and sends
# full timestamps where the API expects YYYY-MM-DD, and its type-mapping option leaves the serialisation code inconsistent.
# So the generator is given a copy of the contract in which `format: date` is dropped (date-time is kept).
set -euo pipefail
cd "$(dirname "$0")/.."

SPEC="$(mktemp -t homeroom-openapi-XXXXXX.yaml)"
trap 'rm -f "$SPEC"' EXIT
node -e '
  const fs = require("fs");
  let s = fs.readFileSync("../backend/openapi.yaml", "utf8");
  s = s.replace(/,\s*format: date(?![-\w])/g, "").replace(/^\s*format: date\s*$/gm, "");
  fs.writeFileSync(process.argv[1], s);
' "$SPEC"

rm -rf packages/homeroom_api
npx --yes @openapitools/openapi-generator-cli@latest generate \
  -i "$SPEC" \
  -g dart \
  -o packages/homeroom_api \
  --additional-properties=pubName=homeroom_api,pubVersion=0.1.0

(cd packages/homeroom_api && flutter pub get >/dev/null && dart analyze)
