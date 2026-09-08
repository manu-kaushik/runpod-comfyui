#!/usr/bin/env bash

# Stop FileBrowser started by start.sh.

set -euo pipefail

PID_FILE=/workspace/filebrowser.pid

if [[ -f "$PID_FILE" ]]; then
    pid="$(cat "$PID_FILE")"
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        echo "stopped FileBrowser (pid $pid)"
    else
        echo "FileBrowser not running (stale pid $pid)"
    fi
    rm -f "$PID_FILE"
elif pkill -x filebrowser 2>/dev/null; then
    echo "stopped FileBrowser"
else
    echo "FileBrowser not running"
fi
