#!/usr/bin/env bash

# Start FileBrowser in the background. Run setup.sh once first.

set -euo pipefail

DB=/workspace/filebrowser.db
LOG=/workspace/filebrowser.log
PID_FILE=/workspace/filebrowser.pid

[[ -f "$DB" ]] || { echo "error: run scripts/filebrowser/setup.sh first" >&2; exit 1; }

if [[ -f "$PID_FILE" ]]; then
    pid="$(cat "$PID_FILE")"
    if kill -0 "$pid" 2>/dev/null; then
        echo "FileBrowser already running (pid $pid)"
        exit 0
    fi
fi

nohup filebrowser -d "$DB" >>"$LOG" 2>&1 &
echo "$!" >"$PID_FILE"
echo "started FileBrowser pid $(cat "$PID_FILE"), log $LOG"
