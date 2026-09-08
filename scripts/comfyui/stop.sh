#!/usr/bin/env bash

# Stop ComfyUI started by start.sh.

set -euo pipefail

source "$(dirname "$0")/../common.sh"

PID_FILE="$COMFYUI/comfyui.pid"

if [[ -f "$PID_FILE" ]]; then
    pid="$(cat "$PID_FILE")"
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        echo "stopped ComfyUI (pid $pid)"
    else
        echo "ComfyUI not running (stale pid $pid)"
    fi
    rm -f "$PID_FILE"
else
    echo "ComfyUI not running (no pid file)"
fi
