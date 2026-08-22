<!-- source: source-of-truth marker -->

# Source

Persistent project record for this repository — not chat history, not summaries. Any agent in any chat reads this file first and updates it when project facts change.

## Overview

RunPod runpod-slim: per-pack `*.sh` scripts copy workflow JSON and curl models into fixed paths. Repository: https://github.com/manu-kaushik/runpod-comfyui

## Current focus

Run pack scripts from terminal after ComfyUI is up. GGUF + Dev Mode in UI.

## Stack

| Layer     | Choice     | Notes                                      |
| --------- | ---------- | ------------------------------------------ |
| Language  | Bash       | Per-pack `*.sh` scripts                    |
| Framework | ComfyUI    | `/workspace/runpod-slim/ComfyUI`           |
| Hosting   | RunPod     | runpod-slim ComfyUI template; volume `/workspace` |

## Repository layout

```
/
  scripts/         # krea.sh, zimage.sh, flux.sh, ltx.sh
  workflows/
  workflows/                             # JSON copied onto the pod
  README.md
  SOURCE.md
  AGENTS.md
```

## Commands

| Task        | Command                                      |
| ----------- | -------------------------------------------- |
| Krea setup  | `bash /workspace/runpod-comfyui/scripts/krea.sh`     |
| Z-Image     | `bash /workspace/runpod-comfyui/scripts/zimage.sh`   |
| Flux i2i    | `bash /workspace/runpod-comfyui/scripts/flux.sh`     |
| LTX         | `bash /workspace/runpod-comfyui/scripts/ltx.sh`      |
| Clone repo  | `git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/runpod-comfyui` |

## Configuration

Fixed paths (no env vars):

- ComfyUI: `/workspace/runpod-slim/ComfyUI`
- Repo: `/workspace/runpod-comfyui`
- Models: `$COMFYUI/models/<type>/`
- Workflows dest: `$COMFYUI/user/default/workflows/`

## Architecture

Each `*.sh`:

1. `cp` workflow JSON from `workflows/`
2. `fetch dest url` — skip if dest exists; else curl with resume to `.part`, then `mv`

ComfyUI-GGUF and Dev Mode: GUI only.

## Decisions

- No `init.sh`, `models.txt`, or `packs.txt` — URLs live in each pack script.
- Fixed runpod-slim paths; no `COMFYUI_PATH`.
- New pack = new `*.sh`; delete unused scripts freely.
- Local model filenames: lowercase, underscore-separated (`krea2_turbo_q4_k_m.gguf`, not upstream `krea2_turbo-Q4_K_M.gguf`). Workflow JSON must match.

## Deferred

- Confirm pack scripts on pod (start with `krea.sh`): models, workflow, GGUF (GUI).
- Final workflow JSON (same filenames in `workflows/`).
- LTX custom nodes when LTX workflow is ready.
- Flux graph must match GGUF filenames (`UnetLoaderGGUF`).
