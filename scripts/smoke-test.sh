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

expect_json_content_type() {
  local url="$1"
  local content_type
  content_type="$(curl --silent --show-error --user "$USER:$PASS" \
    --output /dev/null --write-out '%{content_type}' \
    --header 'Accept: application/json' "$url")"
  if [[ "$content_type" != application/json* ]]; then
    echo "Expected JSON content type from $url, got '$content_type'" >&2
    exit 1
  fi
}

echo "[1/9] Checking Control Center UI"
curl --fail --silent --show-error "$BASE_URL/iris-control-center/" >/dev/null

echo "[2/9] Checking browser assets"
curl --fail --silent --show-error "$BASE_URL/iris-control-center/app.js" >/dev/null
curl --fail --silent --show-error "$BASE_URL/iris-control-center/app.css" >/dev/null

echo "[3/9] Checking API health contract"
expect_json_content_type "$API/health"
health="$(curl_json "$API/health")"
printf '%s' "$health" | grep -q '"status":"ok"'
printf '%s' "$health" | grep -q '"application":"IRIS Control Center"'
printf '%s' "$health" | grep -q '"namespace"'

echo "[4/9] Checking service discovery contract"
expect_json_content_type "$API/services"
services="$(curl_json "$API/services")"
printf '%s' "$services" | grep -q '"services"'
printf '%s' "$services" | grep -q '"source"'
printf '%s' "$services" | grep -q '"count"'
if printf '%s' "$services" | grep -q '"error"'; then
  echo "Service discovery returned an error payload:" >&2
  printf '%s\n' "$services" >&2
  exit 1
fi

echo "[5/9] Checking OpenAPI input validation"
expect_status 400 "$API/openapi"

echo "[6/9] Checking request proxy input validation"
expect_status 400 "$API/request"
expect_status 400 "$API/request?service=missing&path=https%3A%2F%2Fexample.com"

echo "[7/9] Checking request proxy traversal protection"
expect_status 400 "$API/request?service=missing&path=%2F..%2Fapi%2Fmgmnt%2F"
expect_status 400 "$API/request?service=missing&path=%2F%252e%252e%2Fapi%2Fmgmnt%2F"

echo "[8/9] Checking unknown service isolation"
expect_status 404 "$API/request?service=__control_center_missing__&path=%2F"

echo "[9/9] Checking unknown OpenAPI service isolation"
expect_status 404 "$API/openapi?service=__control_center_missing__"

echo "IRIS Control Center smoke test passed."
