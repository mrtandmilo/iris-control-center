#!/usr/bin/env bash
# Zero-cost preflight only. Does not start IRIS, call an LLM, or submit an entry.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
image="${IRIS_AI_HUB_IMAGE:-iris-community:2026.3.0AI.154.0}"
mode="${AGENTIC_MODE:-fixture}"

if [[ "$mode" != fixture ]]; then
  echo 'BLOCKED: preflight requires AGENTIC_MODE=fixture; live calls need separate approval.' >&2
  exit 2
fi
if [[ -z "${IRIS_PASSWORD:-}" || "$IRIS_PASSWORD" == SYS ]]; then
  echo 'BLOCKED: set a non-default IRIS_PASSWORD locally; value is never printed.' >&2
  exit 3
fi
if ! command -v docker >/dev/null 2>&1; then
  echo 'BLOCKED: Docker CLI not installed.' >&2
  exit 4
fi
if ! docker compose version >/dev/null 2>&1; then
  echo 'BLOCKED: Docker Compose not available.' >&2
  exit 5
fi
if ! docker image inspect "$image" >/dev/null 2>&1; then
  echo 'BLOCKED: authorised AI Hub Community build-154 image is not loaded/retagged.' >&2
  echo 'Download from InterSystems Early Access portal; never redistribute the image.' >&2
  exit 6
fi
if ! docker compose -f "$root/agentic/docker-compose.yml" config --quiet >/dev/null 2>&1; then
  echo 'BLOCKED: agentic Docker Compose configuration is invalid.' >&2
  exit 7
fi
if ! node --test "$root/agentic/tests/contract.test.mjs" >/dev/null 2>&1; then
  echo 'BLOCKED: agentic static contract tests failed.' >&2
  exit 8
fi
printf 'PREFLIGHT PASS: fixture prerequisites and static contracts; no runtime execution performed.\n'
printf 'NEXT: docker compose -f agentic/docker-compose.yml up --build -d; then run authenticated runtime-http-check.mjs.\n'
