#!/usr/bin/env bash

# One-time FileBrowser setup (auth, port 8080, root /workspace).
# Installs the binary to /workspace/bin if not on PATH (newer RunPod PyTorch images).

set -euo pipefail

DB=/workspace/filebrowser.db
FILEBROWSER_VERSION="${FILEBROWSER_VERSION:-v2.63.23}"
FILEBROWSER_BIN=/workspace/bin/filebrowser

die() {
    echo "error: $*" >&2
    exit 1
}

ensure_filebrowser() {
    if [[ -x "$FILEBROWSER_BIN" ]]; then
        return 0
    fi
    if command -v filebrowser >/dev/null 2>&1; then
        return 0
    fi

    command -v curl >/dev/null 2>&1 || die "curl is required to install filebrowser"
    command -v tar >/dev/null 2>&1 || die "tar is required to install filebrowser"

    echo "installing filebrowser ${FILEBROWSER_VERSION} -> ${FILEBROWSER_BIN}"
    mkdir -p /workspace/bin
    local tmpdir
    tmpdir="$(mktemp -d)"
    curl -fsSL --retry 3 --retry-delay 2 \
        "https://github.com/filebrowser/filebrowser/releases/download/${FILEBROWSER_VERSION}/linux-amd64-filebrowser.tar.gz" \
        | tar -xzf - -C "$tmpdir"
    install -m 755 "$tmpdir/filebrowser" "$FILEBROWSER_BIN"
    rm -rf "$tmpdir"
    echo "ok filebrowser ${FILEBROWSER_VERSION}"
}

filebrowser_cmd() {
    if [[ -x "$FILEBROWSER_BIN" ]]; then
        echo "$FILEBROWSER_BIN"
    elif command -v filebrowser >/dev/null 2>&1; then
        command -v filebrowser
    else
        die "filebrowser not found after install attempt"
    fi
}

ensure_filebrowser
FB="$(filebrowser_cmd)"

if [[ -f "$DB" ]]; then
    echo "skip setup ($DB exists)"
    exit 0
fi

"$FB" -d "$DB" config init
"$FB" -d "$DB" config set --address 0.0.0.0
"$FB" -d "$DB" config set --port 8080
"$FB" -d "$DB" config set --root /workspace
"$FB" -d "$DB" config set --auth.method json
"$FB" -d "$DB" users add admin "${FILEBROWSER_PASSWORD:-AdminAdmin#123}" --perm.admin

echo "ok FileBrowser setup ($DB)"
echo "login: admin / ${FILEBROWSER_PASSWORD:-AdminAdmin#123}"
echo "start: bash $(dirname "$0")/start.sh"
