#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"
default_dir="$project_root/paper/default"
env_file="$project_root/.env"

if [[ ! -d "$project_root/.git" ]]; then
  echo "This command must be run from a clone of the latex template repository." >&2
  exit 1
fi

if [[ -n "$(git -C "$project_root" status --porcelain --untracked-files=normal)" ]]; then
  echo "The repository has tracked or untracked changes." >&2
  echo "Commit or remove them before importing an Overleaf project." >&2
  exit 1
fi

read -r -p "Overleaf Git URL: " overleaf_url

overleaf_username_default=""
clone_url="$overleaf_url"

if [[ "$overleaf_url" =~ ^(https?://)([^/@]+)@(.+)$ ]]; then
  overleaf_username_default="${BASH_REMATCH[2]}"
  clone_url="${BASH_REMATCH[1]}${BASH_REMATCH[3]}"
fi

if [[ -n "$overleaf_username_default" ]]; then
  read -r -p "Overleaf username [$overleaf_username_default]: " overleaf_username
  overleaf_username="${overleaf_username:-$overleaf_username_default}"
else
  read -r -p "Overleaf username: " overleaf_username
fi

read -r -s -p "Overleaf password/token: " overleaf_password
printf '\n'

if [[ -z "$clone_url" || -z "$overleaf_username" || -z "$overleaf_password" ]]; then
  echo "URL, username, and password/token are required." >&2
  exit 1
fi

printf 'This will replace the contents of %s and replace the template Git history with the Overleaf project history.\n' "$default_dir"
read -r -p "Continue? [y/N] " confirmation
if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
  echo "Setup cancelled."
  exit 0
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/latex-overleaf.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

askpass="$tmp_dir/askpass.sh"
cat > "$askpass" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  *Username*) printf '%s\n' "$OVERLEAF_USERNAME" ;;
  *) printf '%s\n' "$OVERLEAF_PASSWORD" ;;
esac
EOF
chmod 700 "$askpass"

echo "Cloning Overleaf project into a temporary directory..."
GIT_ASKPASS="$askpass" \
GIT_TERMINAL_PROMPT=0 \
OVERLEAF_USERNAME="$overleaf_username" \
OVERLEAF_PASSWORD="$overleaf_password" \
git clone "$clone_url" "$tmp_dir/overleaf-project"

umask 077
{
  printf 'GIT_REMOTE_URL=%q\n' "$clone_url"
  printf 'GIT_USERNAME=%q\n' "$overleaf_username"
  printf 'GIT_PASSWORD=%q\n' "$overleaf_password"
} > "$env_file"

mkdir -p "$default_dir"
find "$default_dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
tar -C "$tmp_dir/overleaf-project" --exclude=.git -cf - . |
  tar -C "$default_dir" -xf -

# The initialized local project belongs to Overleaf, not the template
# repository. Adopting Overleaf's metadata retains its normal origin remote and
# makes the imported layout the next commit in that project's history.
rm -rf "$project_root/.git"
cp -a "$tmp_dir/overleaf-project/.git" "$project_root/.git"

git -C "$project_root" config core.fileMode false

cat <<EOF

Overleaf project imported into:
  $default_dir

The template Git history has been discarded locally. The Overleaf project is
now this repository's 'origin' remote. Open the project in its devcontainer
and configure Git credentials there with:

  ./scripts/setup_git_credentials.sh

Adjust the imported files as needed, then commit and push with:

  git add -A
  git commit -m "Import Overleaf manuscript into template layout"
  git push origin HEAD:master
EOF
