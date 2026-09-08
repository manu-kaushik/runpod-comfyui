#!/usr/bin/env bash

# One-time FileBrowser setup (auth, port 8080, root /workspace).

set -euo pipefail

DB=/workspace/filebrowser.db

die() {
    echo "error: $*" >&2
    exit 1
}

command -v filebrowser >/dev/null 2>&1 \
    || die "filebrowser not found — included on RunPod PyTorch images"

if [[ -f "$DB" ]]; then
    echo "skip setup ($DB exists)"
    exit 0
fi

filebrowser -d "$DB" config init
filebrowser -d "$DB" config set --address 0.0.0.0
filebrowser -d "$DB" config set --port 8080
filebrowser -d "$DB" config set --root /workspace
filebrowser -d "$DB" config set --auth.method json
filebrowser -d "$DB" users add admin "${FILEBROWSER_PASSWORD:-adminadmin12}" --perm.admin

echo "ok FileBrowser setup ($DB)"
echo "login: admin / ${FILEBROWSER_PASSWORD:-adminadmin12}"
echo "start: bash $(dirname "$0")/start.sh"
