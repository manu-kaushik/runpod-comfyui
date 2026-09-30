<!-- source: source-of-truth marker -->

# Source

Persistent project record for this repository — not chat history, not summaries. Any agent in any chat reads this file first and updates it when project facts change.

## Overview

RunPod: PyTorch path — `scripts/comfyui/setup.sh` then `scripts/packs/*.sh`. RunPod ComfyUI template — `scripts/custom-setup.sh` (Krea + MiniMax). Repository: https://github.com/manu-kaushik/runpod-comfyui

## Current focus

Two images documented: PyTorch (full packs) and `runpod/comfyui:1.3.3-comfyuiv0.30.0-cuda12.8` (custom-setup).

## Stack

| Layer     | Choice     | Notes                                      |
| --------- | ---------- | ------------------------------------------ |
| Language  | Bash       | install + per-pack `*.sh` scripts          |
| Framework | ComfyUI    | `/workspace/comfyui`                       |
| Hosting   | RunPod     | PyTorch or ComfyUI template; volume `/workspace` |

## Repository layout

```
/
  config/          # extra_model_paths.yaml → ComfyUI
  scripts/
    common.sh
    custom-setup.sh  # RunPod ComfyUI template (Krea + MiniMax)
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
| RunPod ComfyUI template (Krea + MiniMax) | `bash /workspace/custom-setup/scripts/custom-setup.sh` |
| Krea setup     | `bash /workspace/custom-setup/scripts/packs/krea.sh` |
| Z-Image        | `bash /workspace/custom-setup/scripts/packs/zimage.sh` |
| Flux i2i       | `bash /workspace/custom-setup/scripts/packs/flux.sh` |
| MiniMax t2v+i2v| `bash /workspace/custom-setup/scripts/packs/minimax.sh` |
| Qwen i2i       | `bash /workspace/custom-setup/scripts/packs/qwen.sh` |
| Clone repo     | `git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/custom-setup` |
| Pod cleanup    | `bash /workspace/custom-setup/scripts/cleanup.sh` |

## Configuration

Fixed paths (no env vars):

- ComfyUI: `/workspace/comfyui`
- Repo: `/workspace/custom-setup`
- Models: `/workspace/models/<type>/` (ComfyUI via `extra_model_paths.yaml`, `is_default: true`)
- Input: `/workspace/input/` (ComfyUI `--input-directory`)
- Output: `/workspace/output/` (ComfyUI `--output-directory`)
- Workflows dest: `$COMFYUI/user/default/workflows/`
- FileBrowser DB: `/workspace/filebrowser.db` (port 8080, root `/workspace`); binary `/workspace/bin/filebrowser` (installed by `filebrowser/setup.sh` when not on PATH)

RunPod PyTorch image (4090-class): `runpod/pytorch:1.3.3-cu1281-torch291-ubuntu2404` (PyTorch 2.9.1, CUDA 12.8.1)

RunPod ComfyUI image: `runpod/comfyui:1.3.3-comfyuiv0.30.0-cuda12.8` — ComfyUI at `/workspace/runpod-slim/ComfyUI`, models under `ComfyUI/models/`; Dev mode via Settings GUI

## Architecture

`scripts/comfyui/setup.sh` (once per volume):

1. Clone pinned ComfyUI tag into `/workspace/comfyui`
2. venv; `pip install -r requirements.txt` excluding torch (keep base image CUDA torch)
3. Clone ComfyUI-GGUF, ComfyUI-Manager, comfyui-krea2edit
4. Install `config/extra_model_paths.yaml` → `$COMFYUI/extra_model_paths.yaml`
5. Write `comfyui_args.txt` (listen 8188, disable API nodes, input/output paths; no `--highvram` — OOM on 24 GB with H3)

Each `scripts/packs/*.sh`:

1. `cp` workflow JSON from `$REPO/workflows/` → ComfyUI user folder
2. `fetch dest url` into `/workspace/models/`

Dev Mode: enabled in `user/default/comfy.settings.json` by `comfyui/setup.sh` (PyTorch path); RunPod ComfyUI template — enable in Settings GUI.

`scripts/custom-setup.sh` (RunPod ComfyUI template only): clone comfyui-krea2edit; `fetch` Krea 2 + MiniMax H3 into `$COMFYUI/models/` (UNET weights → `models/unet/`); then `rm -rf /workspace/custom-setup`. Workflows uploaded manually (see README).

## Decisions

- Custom ComfyUI on PyTorch pod instead of official RunPod ComfyUI template (pinned old core).
- Models live on `/workspace/models/`; ComfyUI reads them via `extra_model_paths.yaml` — no symlinks.
- Input/output via ComfyUI CLI args, not symlinks.
- `COMFYUI_REF` env overrides default tag (`v0.37.0`).
- No `models.txt`, or `packs.txt` — URLs live in each pack script.
- New pack = new `scripts/packs/*.sh`; delete unused scripts freely.
- Pack roles: Krea 2 t2i + i2i (comfyui-krea2edit); Z-Image t2i; Flux i2i; MiniMax H3 video (t2v + i2v); Qwen Image Edit 2511 i2i.
- RunPod ComfyUI template (`runpod/comfyui:1.3.3-comfyuiv0.30.0-cuda12.8`): `/workspace/runpod-slim/ComfyUI`, models in `ComfyUI/models/`; `scripts/custom-setup.sh` clones comfyui-krea2edit + curls Krea/MiniMax weights (no `extra_model_paths.yaml`). Dev mode via Settings GUI.
- Krea 2 pack: workflows `text_to_image_krea_2.json`, `image_to_image_krea_2.json`; LoRAs filterbypass3, realism engine v2, realism v2, identity edit v1.2.
- Local model filenames: lowercase, underscore-separated. Workflow JSON must match.
- Scripts grouped: `comfyui/`, `filebrowser/`, `packs/`; shared `scripts/common.sh`.
- After clone on pod, run `scripts/cleanup.sh` to drop `.git`, `.gitignore`, `README.md`, `SOURCE.md`, `AGENTS.md`.
- Stay on CUDA 12.8 (`cu1281`) for 4090-class pods; CUDA 13 only for Blackwell with fresh venv and full pack re-test.
- ComfyUI launch: default VRAM management (no `--highvram`); `--highvram` OOMs MiniMax H3 on 4090 24 GB.
- After changing RunPod PyTorch image, recreate `/workspace/comfyui/.venv` (or `FRESH=true` setup) so extensions match image torch.
- FileBrowser: `FILEBROWSER_VERSION` (default `v2.63.23`) overrides the GitHub release fetched when the binary is missing.

## Deferred

- Confirm install + pack scripts on PyTorch pod: torch, ComfyUI start, GGUF, Dev Mode, one workflow per pack.
- CUDA 13 migration: e.g. `runpod/pytorch:1.0.2-cu1300-torch291-ubuntu2404`; requires host driver R580+, not a drop-in swap.
