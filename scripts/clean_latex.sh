#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 path/to/document.tex" >&2
  exit 1
fi

tex_file="$1"
tex_file="$(readlink -f "$tex_file")"
tex_dir="$(dirname "$tex_file")"
build_dir="$tex_dir/out"

if [[ ! -d "$build_dir" ]]; then
  echo "No build directory found at $build_dir"
  exit 0
fi

echo "Cleaning build files in $build_dir"
find "$build_dir" -mindepth 1 -type f ! -name '*.pdf' -delete
find "$build_dir" -mindepth 1 -type d -empty -delete
