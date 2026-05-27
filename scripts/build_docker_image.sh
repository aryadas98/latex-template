#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"
image_name="mylatex-template:dev"

echo "Building Docker image: $image_name"
docker build --tag "$image_name" --file "$project_root/Dockerfile" "$project_root"
