#!/usr/bin/env bash
set -euo pipefail

# InterSystems' iris-main changes the predefined account passwords only through
# --password-file. Keep the password out of the image and create the file only
# inside the disposable/runtime container.
if [[ -z "${IRIS_PASSWORD:-}" ]]; then
  echo "IRIS_PASSWORD must be set." >&2
  exit 2
fi

password_file="$(mktemp /tmp/iris-password.XXXXXX)"
chmod 600 "$password_file"
# The vendor password API consumes the complete file contents as the password.
# Do not append a line terminator: it becomes part of the supplied credential.
printf '%s' "$IRIS_PASSWORD" > "$password_file"
unset IRIS_PASSWORD

exec /iris-main --password-file "$password_file" --check-caps false
