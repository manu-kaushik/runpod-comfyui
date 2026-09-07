<!-- source: source-of-truth marker -->

# Source

Persistent project record for this repository — not chat history, not summaries. Any agent in any chat reads this file first and updates it when project facts change.

## Overview

RunPod: `install-comfyui.sh` on a PyTorch pod, then per-pack `*.sh` scripts copy workflow JSON and curl models. Repository: https://github.com/manu-kaushik/runpod-comfyui

## Current focus

Custom ComfyUI on RunPod PyTorch base; models on `/workspace/models`. Run install once, then pack scripts.

## Stack

| Layer     | Choice     | Notes                                      |
| --------- | ---------- | ------------------------------------------ |
| Language  | Bash       | install + per-pack `*.sh` scripts          |
| Framework | ComfyUI    | `/workspace/comfyui`                       |
| Hosting   | RunPod     | PyTorch template; volume `/workspace`      |

## Repository layout

```
/
  config/          # extra_model_paths.yaml → ComfyUI
  scripts/         # install-comfyui.sh, start-comfyui.sh, common.sh, krea.sh, …
  workflows/
  README.md
  SOURCE.md
  AGENTS.md
```

## Commands

| Task           | Command                                              |
| -------------- | ---------------------------------------------------- |
| Install ComfyUI| `bash /workspace/custom-setup/scripts/install-comfyui.sh` |
| Start ComfyUI  | `bash /workspace/custom-setup/scripts/start-comfyui.sh` |
| Krea setup     | `bash /workspace/custom-setup/scripts/krea.sh`     |
| Z-Image        | `bash /workspace/custom-setup/scripts/zimage.sh`   |
| Flux i2i       | `bash /workspace/custom-setup/scripts/flux.sh`     |
| LTX t2v+i2v    | `bash /workspace/custom-setup/scripts/ltx.sh`      |
| MiniMax t2v+i2v| `bash /workspace/custom-setup/scripts/minimax.sh` |
| Qwen i2i       | `bash /workspace/custom-setup/scripts/qwen.sh`       |
| Clone repo     | `git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/custom-setup` |

## Configuration

Fixed paths (no env vars):

- ComfyUI: `/workspace/comfyui`
- Repo: `/workspace/custom-setup`
- Models: `/workspace/models/<type>/` (ComfyUI via `extra_model_paths.yaml`, `is_default: true`)
- Input: `/workspace/input/` (ComfyUI `--input-directory`)
- Output: `/workspace/output/` (ComfyUI `--output-directory`)
- Workflows dest: `$COMFYUI/user/default/workflows/`

RunPod PyTorch image (4090-class): `runpod/pytorch:1.0.2-cu1281-torch271-ubuntu2404`

## Architecture

`install-comfyui.sh` (once per pod):

1. Clone pinned ComfyUI tag into `/workspace/comfyui`
2. venv; `pip install -r requirements.txt` excluding torch (keep base image CUDA torch)
3. Clone ComfyUI-GGUF + ComfyUI-Manager
4. Install `config/extra_model_paths.yaml` → `$COMFYUI/extra_model_paths.yaml`
5. Write `comfyui_args.txt` (listen 8188, input/output paths)

Each pack `*.sh`:

1. `cp` workflow JSON from `$REPO/workflows/` → ComfyUI user folder
2. `fetch dest url` into `/workspace/models/`

Dev Mode: enabled in `user/default/comfy.settings.json` by `install-comfyui.sh`.

## Decisions

- Custom ComfyUI on PyTorch pod instead of official RunPod ComfyUI template (pinned old core).
- Models live on `/workspace/models/`; ComfyUI reads them via `extra_model_paths.yaml` — no symlinks.
- Input/output via ComfyUI CLI args, not symlinks.
- `COMFYUI_REF` env overrides default tag (`v0.34.0`).
- No `models.txt`, or `packs.txt` — URLs live in each pack script.
- New pack = new `*.sh`; delete unused scripts freely.
- Pack roles: Krea/Z-Image t2i; Flux i2i; LTX video (t2v + i2v); MiniMax H3 video (t2v + i2v); Qwen Image Edit 2511 i2i.
- Local model filenames: lowercase, underscore-separated. Workflow JSON must match.

## Deferred

- Confirm install + pack scripts on PyTorch pod: torch, ComfyUI start, GGUF, Dev Mode, one workflow per pack.
