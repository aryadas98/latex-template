#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 path/to/main.tex" >&2
  exit 1
fi

tex_path="$1"
tex_path="$(readlink -f "$tex_path")"

if [[ ! -f "$tex_path" && -f "${tex_path}.tex" ]]; then
  tex_path="${tex_path}.tex"
fi

if [[ ! -f "$tex_path" ]]; then
  echo "Document not found: $tex_path" >&2
  exit 1
fi

tex_dir="$(dirname "$tex_path")"
tex_file="$(basename "$tex_path")"

if ! project_root="$(git -C "$tex_dir" rev-parse --show-toplevel 2>/dev/null)"; then
  echo "Document must be inside a Git repository: $tex_path" >&2
  exit 1
fi

paper_dir="$project_root/paper"
if [[ ! -d "$paper_dir" ]]; then
  echo "Expected template paper directory not found: $paper_dir" >&2
  exit 1
fi

out_dir="$tex_dir/out"

mkdir -p "$out_dir"

if compgen -G "$paper_dir/figures/*.eps" >/dev/null; then
  if ! command -v epstopdf >/dev/null 2>&1; then
    echo "epstopdf is required to convert EPS figures but was not found." >&2
    exit 1
  fi

  for eps_file in "$paper_dir"/figures/*.eps; do
    eps_name="$(basename "$eps_file" .eps)"
    pdf_file="$out_dir/${eps_name}-eps-converted-to.pdf"

    if [[ ! -f "$pdf_file" || "$eps_file" -nt "$pdf_file" ]]; then
      epstopdf "$eps_file" --outfile="$pdf_file"
    fi
  done
fi

export BIBINPUTS="$paper_dir/bibliography:$tex_dir:$project_root:$out_dir:"
export BSTINPUTS="$tex_dir:$project_root:$out_dir:"
export TEXINPUTS="$out_dir:$paper_dir/figures:$paper_dir:$tex_dir:"

cd "$tex_dir"

latexmk \
  -pdf \
  -shell-escape \
  -synctex=1 \
  -interaction=nonstopmode \
  -file-line-error \
  -outdir="$out_dir" \
  -auxdir="$out_dir" \
  "$tex_file"
