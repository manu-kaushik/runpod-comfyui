#!/usr/bin/env bash

# Start FileBrowser in the background. Run setup.sh once first.

set -euo pipefail

DB=/workspace/filebrowser.db
LOG=/workspace/filebrowser.log
PID_FILE=/workspace/filebrowser.pid
FILEBROWSER_BIN=/workspace/bin/filebrowser

[[ -f "$DB" ]] || { echo "error: run scripts/filebrowser/setup.sh first" >&2; exit 1; }

if [[ -x "$FILEBROWSER_BIN" ]]; then
    FB="$FILEBROWSER_BIN"
elif command -v filebrowser >/dev/null 2>&1; then
    FB="$(command -v filebrowser)"
else
    echo "error: filebrowser not found — run scripts/filebrowser/setup.sh first" >&2
    exit 1
fi

if [[ -f "$PID_FILE" ]]; then
    pid="$(cat "$PID_FILE")"
    if kill -0 "$pid" 2>/dev/null; then
        echo "FileBrowser already running (pid $pid)"
        exit 0
    fi
fi

nohup "$FB" -d "$DB" >>"$LOG" 2>&1 &
echo "$!" >"$PID_FILE"
echo "started FileBrowser pid $(cat "$PID_FILE"), log $LOG"
