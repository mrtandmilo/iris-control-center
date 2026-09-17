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

expect_status() {
  local expected="$1"
  local url="$2"
  local actual
  actual="$(curl --silent --output /dev/null --write-out '%{http_code}' \
    --user "$USER:$PASS" --header 'Accept: application/json' "$url")"
  if [[ "$actual" != "$expected" ]]; then
    echo "Expected HTTP $expected from $url, got $actual" >&2
    exit 1
  fi
}

echo "[1/7] Checking Control Center UI"
curl --fail --silent --show-error "$BASE_URL/iris-control-center/" >/dev/null

echo "[2/7] Checking browser assets"
curl --fail --silent --show-error "$BASE_URL/iris-control-center/app.js" >/dev/null
curl --fail --silent --show-error "$BASE_URL/iris-control-center/app.css" >/dev/null

echo "[3/7] Checking API health"
health="$(curl_json "$API/health")"
printf '%s' "$health" | grep -q '"status":"ok"'
printf '%s' "$health" | grep -q '"application":"IRIS Control Center"'

echo "[4/7] Checking service discovery"
services="$(curl_json "$API/services")"
printf '%s' "$services" | grep -q '"services"'
if printf '%s' "$services" | grep -q '"error"'; then
  echo "Service discovery returned an error payload:" >&2
  printf '%s\n' "$services" >&2
  exit 1
fi

echo "[5/7] Checking OpenAPI input validation"
expect_status 400 "$API/openapi"

echo "[6/7] Checking request proxy input validation"
expect_status 400 "$API/request"
expect_status 400 "$API/request?service=missing&path=https%3A%2F%2Fexample.com"

echo "[7/7] Checking unknown service isolation"
expect_status 404 "$API/request?service=__control_center_missing__&path=%2F"

echo "IRIS Control Center smoke test passed."
