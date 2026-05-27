#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"
env_file="$project_root/.env"
cred_file="$HOME/.git-credentials"

if [[ ! -f "$env_file" ]]; then
  echo "Missing $env_file" >&2
  echo "Create it from .env_template first." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$env_file"
set +a

if [[ -z "${GIT_REMOTE_URL:-}" || -z "${GIT_USERNAME:-}" || -z "${GIT_PASSWORD:-}" ]]; then
  echo "GIT_REMOTE_URL, GIT_USERNAME, and GIT_PASSWORD must all be set in $env_file" >&2
  exit 1
fi

protocol_host="${GIT_REMOTE_URL#http://}"
protocol_host="${protocol_host#https://}"
protocol_host="${protocol_host%%/*}"

mkdir -p "$HOME"
printf 'https://%s:%s@%s\n' "$GIT_USERNAME" "$GIT_PASSWORD" "$protocol_host" > "$cred_file"
chmod 600 "$cred_file"

git config --global credential.helper store

echo "Wrote credentials to $cred_file"
echo "Configured Git to use credential.helper=store"
