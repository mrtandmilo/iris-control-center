#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:52773}"
USER="${IRIS_USER:-_SYSTEM}"
PASS="${IRIS_PASSWORD:-}"
API="$BASE_URL/iris-control-center/api"
READY_TIMEOUT="${READY_TIMEOUT:-180}"
READY_INTERVAL="${READY_INTERVAL:-3}"
REQUEST_TIMEOUT="${REQUEST_TIMEOUT:-15}"

if [[ -z "$PASS" ]]; then
  echo "IRIS_PASSWORD must be set for authenticated runtime validation." >&2
  exit 2
fi

require_positive_integer() {
  local name="$1"
  local value="$2"
  if [[ ! "$value" =~ ^[1-9][0-9]*$ ]]; then
    echo "$name must be a positive integer number of seconds (got '$value')." >&2
    exit 2
  fi
}

require_positive_integer READY_TIMEOUT "$READY_TIMEOUT"
require_positive_integer READY_INTERVAL "$READY_INTERVAL"
require_positive_integer REQUEST_TIMEOUT "$REQUEST_TIMEOUT"

curl_json() {
  curl --fail --silent --show-error --max-time "$REQUEST_TIMEOUT" --user "$USER:$PASS" \
    --header 'Accept: application/json' "$1"
}

expect_status() {
  local expected="$1"
  local url="$2"
  local actual
  actual="$(curl --silent --output /dev/null --write-out '%{http_code}' \
    --max-time "$REQUEST_TIMEOUT" --user "$USER:$PASS" --header 'Accept: application/json' "$url")"
  if [[ "$actual" != "$expected" ]]; then
    echo "Expected HTTP $expected from $url, got $actual" >&2
    exit 1
  fi
}

expect_unauthenticated_status() {
  local expected="$1"
  local url="$2"
  local actual
  actual="$(curl --silent --output /dev/null --write-out '%{http_code}' \
    --max-time "$REQUEST_TIMEOUT" --header 'Accept: application/json' "$url")"
  if [[ "$actual" != "$expected" ]]; then
    echo "Expected unauthenticated HTTP $expected from $url, got $actual" >&2
    exit 1
  fi
}

expect_json_content_type() {
  local url="$1"
  local content_type
  content_type="$(curl --silent --show-error --max-time "$REQUEST_TIMEOUT" --user "$USER:$PASS" \
    --output /dev/null --write-out '%{content_type}' \
    --header 'Accept: application/json' "$url")"
  if [[ "$content_type" != application/json* ]]; then
    echo "Expected JSON content type from $url, got '$content_type'" >&2
    exit 1
  fi
}

expect_json_error() {
  local expected_status="$1"
  local expected_error="$2"
  local url="$3"
  local body_file
  local status
  local content_type
  body_file="$(mktemp)"
  trap 'rm -f "$body_file"' RETURN
  status="$(curl --silent --show-error --max-time "$REQUEST_TIMEOUT" --user "$USER:$PASS" \
    --output "$body_file" --write-out '%{http_code}' --header 'Accept: application/json' "$url")"
  content_type="$(curl --silent --show-error --max-time "$REQUEST_TIMEOUT" --user "$USER:$PASS" \
    --output /dev/null --write-out '%{content_type}' --header 'Accept: application/json' "$url")"
  if [[ "$status" != "$expected_status" ]]; then
    echo "Expected HTTP $expected_status from $url, got $status" >&2
    cat "$body_file" >&2
    exit 1
  fi
  if [[ "$content_type" != application/json* ]]; then
    echo "Expected JSON content type from $url, got '$content_type'" >&2
    exit 1
  fi
  if ! grep -q "\"error\":\"$expected_error\"" "$body_file"; then
    echo "Expected error code '$expected_error' from $url, got:" >&2
    cat "$body_file" >&2
    exit 1
  fi
  rm -f "$body_file"
  trap - RETURN
}

wait_for_control_center() {
  local deadline=$((SECONDS + READY_TIMEOUT))
  local status="000"

  echo "Waiting up to ${READY_TIMEOUT}s for IRIS Control Center readiness..."
  while (( SECONDS < deadline )); do
    status="$(curl --silent --output /dev/null --write-out '%{http_code}' \
      --user "$USER:$PASS" --header 'Accept: application/json' \
      --connect-timeout 2 --max-time 5 "$API/health" || true)"
    if [[ "$status" == "200" ]]; then
      echo "IRIS Control Center is ready."
      return 0
    fi
    sleep "$READY_INTERVAL"
  done

  echo "Timed out waiting for $API/health (last HTTP status: $status)." >&2
  echo "Check container health and IRIS setup/compile logs before retrying." >&2
  return 1
}

wait_for_control_center

echo "[1/10] Checking Control Center UI"
curl --fail --silent --show-error --max-time "$REQUEST_TIMEOUT" "$BASE_URL/iris-control-center/" >/dev/null

echo "[2/10] Checking browser assets"
curl --fail --silent --show-error --max-time "$REQUEST_TIMEOUT" "$BASE_URL/iris-control-center/app.js" >/dev/null
curl --fail --silent --show-error --max-time "$REQUEST_TIMEOUT" "$BASE_URL/iris-control-center/app.css" >/dev/null

echo "[3/10] Checking API authentication boundary"
expect_unauthenticated_status 401 "$API/health"

echo "[4/10] Checking API health contract"
expect_json_content_type "$API/health"
health="$(curl_json "$API/health")"
printf '%s' "$health" | grep -q '"status":"ok"'
printf '%s' "$health" | grep -q '"application":"IRIS Control Center"'
printf '%s' "$health" | grep -q '"namespace"'

echo "[5/10] Checking service discovery contract"
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

echo "[6/10] Checking OpenAPI input validation"
expect_json_error 400 service_required "$API/openapi"

echo "[7/10] Checking request proxy input validation"
expect_json_error 400 service_and_path_required "$API/request"
expect_json_error 400 invalid_path "$API/request?service=missing&path=https%3A%2F%2Fexample.com"

echo "[8/10] Checking request proxy traversal protection"
expect_json_error 400 invalid_path "$API/request?service=missing&path=%2F..%2Fapi%2Fmgmnt%2F"
expect_json_error 400 invalid_path "$API/request?service=missing&path=%2F%252e%252e%2Fapi%2Fmgmnt%2F"

echo "[9/10] Checking unknown service isolation"
expect_json_error 404 service_not_found "$API/request?service=__control_center_missing__&path=%2F"

echo "[10/10] Checking unknown OpenAPI service isolation"
expect_json_error 404 service_not_found "$API/openapi?service=__control_center_missing__"

echo "IRIS Control Center smoke test passed."
