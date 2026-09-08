<!-- source: source-of-truth marker -->

# Source

Persistent project record for this repository — not chat history, not summaries. Any agent in any chat reads this file first and updates it when project facts change.

## Overview

RunPod: `scripts/comfyui/setup.sh` on a PyTorch pod, then per-pack `scripts/packs/*.sh` copy workflow JSON and curl models. Repository: https://github.com/manu-kaushik/runpod-comfyui

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
  scripts/
    common.sh
    comfyui/       # setup.sh, start.sh, stop.sh
    filebrowser/   # setup.sh, start.sh, stop.sh
    packs/         # krea.sh, zimage.sh, …
  workflows/
  README.md
  SOURCE.md
  AGENTS.md
```

## Commands

| Task           | Command                                              |
| -------------- | ---------------------------------------------------- |
| Install ComfyUI| `bash /workspace/custom-setup/scripts/comfyui/setup.sh` |
| Start ComfyUI  | `bash /workspace/custom-setup/scripts/comfyui/start.sh` |
| Stop ComfyUI   | `bash /workspace/custom-setup/scripts/comfyui/stop.sh` |
| FileBrowser setup | `bash /workspace/custom-setup/scripts/filebrowser/setup.sh` |
| FileBrowser start | `bash /workspace/custom-setup/scripts/filebrowser/start.sh` |
| FileBrowser stop  | `bash /workspace/custom-setup/scripts/filebrowser/stop.sh` |
| Krea setup     | `bash /workspace/custom-setup/scripts/packs/krea.sh` |
| Z-Image        | `bash /workspace/custom-setup/scripts/packs/zimage.sh` |
| Flux i2i       | `bash /workspace/custom-setup/scripts/packs/flux.sh` |
| LTX t2v+i2v    | `bash /workspace/custom-setup/scripts/packs/ltx.sh` |
| MiniMax t2v+i2v| `bash /workspace/custom-setup/scripts/packs/minimax.sh` |
| Qwen i2i       | `bash /workspace/custom-setup/scripts/packs/qwen.sh` |
| Clone repo     | `git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/custom-setup` |

## Configuration

Fixed paths (no env vars):

- ComfyUI: `/workspace/comfyui`
- Repo: `/workspace/custom-setup`
- Models: `/workspace/models/<type>/` (ComfyUI via `extra_model_paths.yaml`, `is_default: true`)
- Input: `/workspace/input/` (ComfyUI `--input-directory`)
- Output: `/workspace/output/` (ComfyUI `--output-directory`)
- Workflows dest: `$COMFYUI/user/default/workflows/`
- FileBrowser DB: `/workspace/filebrowser.db` (port 8080, root `/workspace`)

RunPod PyTorch image (4090-class): `runpod/pytorch:1.0.2-cu1281-torch271-ubuntu2404`

## Architecture

`scripts/comfyui/setup.sh` (once per volume):

1. Clone pinned ComfyUI tag into `/workspace/comfyui`
2. venv; `pip install -r requirements.txt` excluding torch (keep base image CUDA torch)
3. Clone ComfyUI-GGUF + ComfyUI-Manager
4. Install `config/extra_model_paths.yaml` → `$COMFYUI/extra_model_paths.yaml`
5. Write `comfyui_args.txt` (listen 8188, input/output paths)

Each `scripts/packs/*.sh`:

1. `cp` workflow JSON from `$REPO/workflows/` → ComfyUI user folder
2. `fetch dest url` into `/workspace/models/`

Dev Mode: enabled in `user/default/comfy.settings.json` by `comfyui/setup.sh`.

## Decisions

- Custom ComfyUI on PyTorch pod instead of official RunPod ComfyUI template (pinned old core).
- Models live on `/workspace/models/`; ComfyUI reads them via `extra_model_paths.yaml` — no symlinks.
- Input/output via ComfyUI CLI args, not symlinks.
- `COMFYUI_REF` env overrides default tag (`v0.34.0`).
- No `models.txt`, or `packs.txt` — URLs live in each pack script.
- New pack = new `scripts/packs/*.sh`; delete unused scripts freely.
- Pack roles: Krea/Z-Image t2i; Flux i2i; LTX video (t2v + i2v); MiniMax H3 video (t2v + i2v); Qwen Image Edit 2511 i2i.
- Local model filenames: lowercase, underscore-separated. Workflow JSON must match.
- Scripts grouped: `comfyui/`, `filebrowser/`, `packs/`; shared `scripts/common.sh`.

## Deferred

- Confirm install + pack scripts on PyTorch pod: torch, ComfyUI start, GGUF, Dev Mode, one workflow per pack.
