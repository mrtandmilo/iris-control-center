#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:52773}"
USER="${IRIS_USER:-_SYSTEM}"
PASS="${IRIS_PASSWORD:-SYS}"
API="$BASE_URL/iris-control-center/api"

curl_json() {
  curl --fail --silent --show-error --user "$USER:$PASS" \
    --header 'Accept: application/json' "$1"
}

echo "[1/4] Checking Control Center UI"
curl --fail --silent --show-error "$BASE_URL/iris-control-center/" >/dev/null

echo "[2/4] Checking API health"
health="$(curl_json "$API/health")"
printf '%s' "$health" | grep -q '"status":"ok"'

echo "[3/4] Checking service discovery"
services="$(curl_json "$API/services")"
printf '%s' "$services" | grep -q '"services"'

echo "[4/4] Checking that the catalogue is JSON-like and non-erroring"
if printf '%s' "$services" | grep -q '"error"'; then
  echo "Service discovery returned an error payload:" >&2
  printf '%s\n' "$services" >&2
  exit 1
fi

echo "IRIS Control Center smoke test passed."
