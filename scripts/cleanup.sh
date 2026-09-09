#!/usr/bin/env bash

# Remove repo/dev files not needed on a RunPod pod. Run once after git clone.
#   bash /workspace/custom-setup/scripts/cleanup.sh

set -euo pipefail

REPO="${1:-/workspace/custom-setup}"

[[ -d "$REPO" ]] || { echo "error: not a directory: $REPO" >&2; exit 1; }

cd "$REPO"

rm -rf .git
rm -f .gitignore SOURCE.md AGENTS.md README.md

echo "ok cleaned $REPO (kept config/, scripts/, workflows/)"
