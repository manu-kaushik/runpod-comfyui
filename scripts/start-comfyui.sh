#!/usr/bin/env bash

# Start ComfyUI in the background (survives terminal exit). Run after install-comfyui.sh.

set -euo pipefail

source "$(dirname "$0")/common.sh"

VENV="$COMFYUI/.venv"
ARGS_FILE="$COMFYUI/comfyui_args.txt"
LOG="$COMFYUI/comfyui.log"
PID_FILE="$COMFYUI/comfyui.pid"

[[ -f "$COMFYUI/main.py" ]] || { echo "error: run install-comfyui.sh first" >&2; exit 1; }
[[ -f "$ARGS_FILE" ]] || { echo "error: missing $ARGS_FILE" >&2; exit 1; }

if [[ -f "$PID_FILE" ]]; then
    pid="$(cat "$PID_FILE")"
    if kill -0 "$pid" 2>/dev/null; then
        echo "ComfyUI already running (pid $pid)"
        exit 0
    fi
fi

# shellcheck disable=SC1091
source "$VENV/bin/activate"
cd "$COMFYUI"

nohup python main.py $(tr '\n' ' ' < "$ARGS_FILE") >>"$LOG" 2>&1 &
echo "$!" >"$PID_FILE"
echo "started ComfyUI pid $(cat "$PID_FILE"), log $LOG"
