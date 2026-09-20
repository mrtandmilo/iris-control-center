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
# changePassword.sh reads the password as a text line. Terminate it with a
# newline so command-line readers do not block waiting for the end of the line.
printf '%s\n' "$IRIS_PASSWORD" > "$password_file"
unset IRIS_PASSWORD

exec /iris-main --password-file "$password_file" --check-caps false
