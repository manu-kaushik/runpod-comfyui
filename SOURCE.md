<!-- source: source-of-truth marker -->

# Source

Persistent project record for this repository — not chat history, not summaries. Any agent in any chat reads this file first and updates it when project facts change.

## Overview

RunPod runpod-slim: per-pack `*.sh` scripts copy workflow JSON and curl models into fixed paths. Repository: https://github.com/manu-kaushik/runpod-comfyui

## Current focus

Run `setup.sh` once per pod, then pack scripts. GGUF + Dev Mode in UI.

## Stack

| Layer     | Choice     | Notes                                      |
| --------- | ---------- | ------------------------------------------ |
| Language  | Bash       | Per-pack `*.sh` scripts                    |
| Framework | ComfyUI    | `/workspace/runpod-slim/ComfyUI`           |
| Hosting   | RunPod     | runpod-slim ComfyUI template; volume `/workspace` |

## Repository layout

```
/
  config/          # extra_model_paths.yaml → ComfyUI
  scripts/         # setup.sh, common.sh, krea.sh, zimage.sh, flux.sh, ltx.sh, minimax.sh, qwen.sh
  workflows/       # repo templates; seeded to /workspace/workflows/ by setup.sh
  README.md
  SOURCE.md
  AGENTS.md
```

## Commands

| Task        | Command                                      |
| ----------- | -------------------------------------------- |
| Pod setup   | `bash /workspace/comfyui-packs/scripts/setup.sh`    |
| Krea setup  | `bash /workspace/comfyui-packs/scripts/krea.sh`     |
| Z-Image     | `bash /workspace/comfyui-packs/scripts/zimage.sh`   |
| Flux i2i    | `bash /workspace/comfyui-packs/scripts/flux.sh`     |
| LTX t2v+i2v | `bash /workspace/comfyui-packs/scripts/ltx.sh`      |
| MiniMax t2v+i2v | `bash /workspace/comfyui-packs/scripts/minimax.sh` |
| Qwen i2i    | `bash /workspace/comfyui-packs/scripts/qwen.sh`       |
| Clone repo  | `git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/comfyui-packs` |

## Configuration

Fixed paths (no env vars):

- ComfyUI: `/workspace/runpod-slim/ComfyUI`
- Repo: `/workspace/comfyui-packs`
- Models: `/workspace/models/<type>/` (via `extra_model_paths.yaml`)
- Workflows source: `/workspace/workflows/`
- Workflows dest: `$COMFYUI/user/default/workflows/` (pack scripts copy)
- Input: `/workspace/input/` (symlinked to `$COMFYUI/input`)
- Output: `/workspace/output/` (symlinked to `$COMFYUI/output`)

## Architecture

Each `*.sh`:

1. `cp` workflow JSON from `/workspace/workflows/` → ComfyUI user folder
2. `fetch dest url` — skip if dest exists; else curl with resume to `.part`, then `mv` into `/workspace/models/`

`setup.sh` (once per pod): create workspace dirs, install `config/extra_model_paths.yaml`, symlink input/output, seed `/workspace/workflows/` from repo templates.

ComfyUI-GGUF and Dev Mode: GUI only.

## Decisions

- No `models.txt`, or `packs.txt` — URLs live in each pack script.
- Fixed runpod-slim paths; no `COMFYUI_PATH`.
- New pack = new `*.sh`; delete unused scripts freely.
- Pack roles: Krea/Z-Image t2i; Flux i2i; LTX video (t2v + i2v); MiniMax H3 video (t2v + i2v); Qwen Image Edit 2511 i2i.
- Local model filenames: lowercase, underscore-separated (`krea2_turbo_q4_k_m.gguf`, not upstream `krea2_turbo-Q4_K_M.gguf`). Workflow JSON must match.

## Deferred

- Confirm pack scripts on pod (start with `krea.sh`): models, workflow, GGUF (GUI).
