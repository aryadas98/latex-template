#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"

claude_data="$project_root/.claude_data"
claude_home="$HOME/.claude"

# Link Claude Code's config directory to an in-repo folder so auth, settings, and
# history persist across container rebuilds. .claude_data must be created manually
# on the host before the first build; this script only ever symlinks to it.
echo "==> Linking ~/.claude -> $claude_data"
if [[ -e "$claude_home" || -L "$claude_home" ]]; then
  rm -rf "$claude_home"
fi
ln -s "$claude_data" "$claude_home"

# Install/update Claude Code via the native installer (binary lands in ~/.local/bin,
# which devcontainer.json adds to PATH). Not baked into the image so it stays current.
echo "==> Installing/updating Claude Code"
curl -fsSL https://claude.ai/install.sh | bash

echo "==> Devcontainer setup complete"
