#!/usr/bin/env bash
set -euo pipefail

# Always operate on this checkout, regardless of the caller's current working
# directory. This prevents docker compose from selecting an unrelated project
# and makes the documented ./scripts/release-validation.sh command reliable
# when invoked through an absolute path or from automation.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

: "${IRIS_IMAGE:?Set IRIS_IMAGE to the exact IRIS Community image tag used for release validation}"
: "${IRIS_PASSWORD:?Set IRIS_PASSWORD before running release validation}"

if [[ "$IRIS_IMAGE" == *":latest" || "$IRIS_IMAGE" == *":latest-"* || "$IRIS_IMAGE" != *":"* ]]; then
  echo "IRIS_IMAGE must use an explicit non-latest tag: $IRIS_IMAGE" >&2
  exit 2
fi

CONTAINER_HEALTH_TIMEOUT="${CONTAINER_HEALTH_TIMEOUT:-240}"
if [[ ! "$CONTAINER_HEALTH_TIMEOUT" =~ ^[1-9][0-9]*$ ]]; then
  echo "CONTAINER_HEALTH_TIMEOUT must be a positive integer number of seconds (got '$CONTAINER_HEALTH_TIMEOUT')." >&2
  exit 2
fi

for command in docker curl git; do
  command -v "$command" >/dev/null 2>&1 || { echo "Required command not found: $command" >&2; exit 2; }
done

docker compose version >/dev/null 2>&1 || { echo "Docker Compose v2 is required" >&2; exit 2; }

printf 'Release validation image: %s\n' "$IRIS_IMAGE"
printf 'Git commit: %s\n' "$(git rev-parse HEAD)"
printf 'Validation UTC: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo 'Removing disposable validation stack and data volume...'
docker compose down -v --remove-orphans

echo 'Building from scratch...'
docker compose build --no-cache

echo 'Starting IRIS...'
docker compose up -d

container_id="$(docker compose ps -q iris)"
if [[ -z "$container_id" ]]; then
  echo 'IRIS container was not created.' >&2
  exit 1
fi

health_deadline=$((SECONDS + CONTAINER_HEALTH_TIMEOUT))
while (( SECONDS < health_deadline )); do
  health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container_id" 2>/dev/null || true)"
  case "$health" in
    healthy) break ;;
    unhealthy|exited|dead)
      echo "IRIS container entered terminal state: $health" >&2
      docker compose logs --no-color iris >&2 || true
      exit 1
      ;;
  esac
  sleep 3
done

health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container_id" 2>/dev/null || true)"
if [[ "$health" != healthy ]]; then
  echo "IRIS did not become healthy before timeout (state: ${health:-unknown})." >&2
  docker compose logs --no-color iris >&2 || true
  exit 1
fi

echo 'Container healthy; running application acceptance suite...'
IRIS_USER="${IRIS_USER:-_SYSTEM}" ./scripts/smoke-test.sh

echo
echo 'Release validation passed.'
echo 'The validated stack is intentionally left running for browser/demo evidence capture.'
echo 'When finished: docker compose down -v --remove-orphans'
