<!-- source: source-of-truth marker -->

# Source

Persistent project record for this repository — not chat history, not summaries. Any agent in any chat reads this file first and updates it when project facts change.

## Overview

RunPod ComfyUI bootstrap: a bash init script that installs pack-selected model weights, placeholder Comfy editor workflows, ComfyUI-GGUF, and Dev Mode on GPU pods running ComfyUI. Repository: https://github.com/manu-kaushik/runpod-comfyui

## Current focus

First real pod boot with init-before-Comfy. Start with `krea` or `zimage` (smaller than `ltx`). Confirm GGUF nodes, Dev Mode, models on disk, and placeholder workflows visible in the UI.

## Stack

| Layer     | Choice              | Notes                                      |
| --------- | ------------------- | ------------------------------------------ |
| Language  | Bash                | `init.sh` bootstrap script                 |
| Framework | ComfyUI             | Target runtime on RunPod                   |
| Database  | —                   | None                                       |
| Hosting   | RunPod              | CUDA 12.8 ComfyUI template; volume on `/workspace` |

## Repository layout

```
/
  init.sh          # RunPod template init script
  packs.txt        # pack names, aliases, jobs, workflow stems
  models.txt       # per-pack curl download manifest
  workflows/       # placeholder Comfy editor JSON (same filenames when finalized)
  README.md        # setup, flags, and usage
  SOURCE.md        # persistent project record (this file)
  AGENTS.md        # agent workflow and boundaries
```

## Commands

| Task              | Command                                                                                      |
| ----------------- | -------------------------------------------------------------------------------------------- |
| List packs        | `bash init.sh --list`                                                                        |
| Dry run (local)   | `bash init.sh zimage --dry-run`                                                              |
| Install pack(s)   | `bash init.sh krea` or `bash init.sh krea flux`                                              |
| Install all packs | `bash init.sh --all`                                                                         |
| RunPod setup      | `git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/runpod-comfyui && bash /workspace/runpod-comfyui/init.sh krea` |

## Configuration

| Variable       | Purpose                                                          |
| -------------- | ---------------------------------------------------------------- |
| `COMFYUI_PATH` | ComfyUI root (auto-detect or override)                           |
| `WORKFLOWS`    | Comma-separated pack names (alias for positional args)           |
| `GGUF_REPO`    | ComfyUI-GGUF git URL (default: `city96/ComfyUI-GGUF`)            |

Auto-detected ComfyUI paths: `/workspace/ComfyUI`, `/workspace/runpod-slim/ComfyUI`, `/ComfyUI`.

Python for pip/settings: Comfy venv if present (`venv`, `.venv`, `python_embeded`), else `python3`/`python`.

## Architecture

`init.sh` flow for each selected pack:

1. Clone/update `custom_nodes/ComfyUI-GGUF` and pip-install requirements (`gguf`).
2. Set `Comfy.DevMode=true` in `user/default/comfy.settings.json`.
3. Copy pack workflow JSON from `workflows/` → `$COMFYUI_PATH/user/default/workflows`.
4. Curl `models.txt` rows into `$COMFYUI_PATH/models/<dest_dir>/<filename>` (dedupe by dest+name; skip existing non-empty files).
5. Restart Comfy **only if already running** (`supervisorctl restart comfyui` or stop/relaunch `main.py`). If not running, template starts Comfy afterward.

Packs (source of truth: `packs.txt` + `models.txt`):

| Pack     | Job                                  | Workflow files                                              |
| -------- | ------------------------------------ | ----------------------------------------------------------- |
| `krea`   | text-to-image                        | `text_to_image_krea_2_turbo.json`                           |
| `zimage` | text-to-image                        | `text_to_image_z_image_turbo.json`                          |
| `flux`   | image-to-image                       | `image_to_image_flux_kontext.json`                          |
| `ltx`    | text-to-video **and** image-to-video | `text_to_video_ltx_2.3.json`, `image_to_video_ltx_2.3.json` |

Krea and Z-Image are **not** i2i. i2i is Flux Kontext only.

## Conventions

- Short pack names: `krea`, `zimage`, `flux`, `ltx`.
- Packs map to job sections, not “every JSON in the folder”.
- `models.txt` format: `pack|dest_dir|filename|url`.
- Hugging Face `/blob/` URLs must be `/resolve/` for curl.
- Placeholder workflow JSON keeps fixed filenames; only content changes when graphs are finalized.

## Constraints

- Template init must run **before** Comfy `main.py`.
- Pod volume on `/workspace` (not `/tmp`).
- Idempotent: existing non-empty model files skipped; git pull for ComfyUI-GGUF.
- Do not kill `main.py` manually on first boot — some templates `sleep infinity` if Comfy is killed.

## External services

- GitHub: `manu-kaushik/runpod-comfyui`, `city96/ComfyUI-GGUF`
- Hugging Face: public model downloads per `models.txt`

## Decisions

- Short pack names (`krea`, `zimage`, `flux`, `ltx`) over long descriptive names.
- Packs = job sections with explicit workflow stems in `packs.txt`.
- Integer-style curl manifest in `models.txt` (`pack|dest_dir|filename|url`).
- Init restarts Comfy only when already running; first boot leaves start to the template.
- Only ComfyUI-GGUF installed by default; LTX-specific custom nodes deferred until LTX workflow is final.
- Unused workflow JSON removed; current placeholders get content-only updates.

## Deferred

- Boot pod with init-before-Comfy and confirm GGUF nodes, Dev Mode, models, workflows.
- Replace placeholder workflow JSON with final editor graphs (same filenames).
- LTX custom nodes — setup when LTX workflow is complete (if required).
- Flux placeholder graph may still reference fp8/`UNETLoader`; final graph must use `UnetLoaderGGUF` + GGUF filenames from `models.txt`.
- Optional after first boot: checksums, tighten Comfy path/python detection from real template layout.
