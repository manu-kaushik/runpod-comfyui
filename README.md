# Runpod ComfyUI

Pod bootstrap for ComfyUI on RunPod.

JSON in `workflows/` is placeholder; **final graphs keep the same filenames**.

```
runpod/
  init.sh          # what the RunPod template should run
  packs.txt        # short pack names + job + workflow filenames
  models.txt       # per-pack download list
  workflows/       # placeholder graphs (same names when replaced)
  README.md        # setup and flags
```

## What the script does

Always, for the packs you name:

1. Install **ComfyUI-GGUF** into `custom_nodes/` and pip-install `gguf`.
2. Enable **Comfy Dev Mode** (`Comfy.DevMode` in `user/default/comfy.settings.json`) — UI **Save (API Format)**.
3. Copy that pack’s placeholder JSON into ComfyUI `user/default/workflows`.
4. Curl that pack’s weights into `$COMFYUI_PATH/models/…`.
5. **Reload ComfyUI if it is already running** so GGUF nodes load. If it is not running yet, do nothing — the template starts Comfy after this script, with GGUF already on disk.

No skip flags. Idempotent (existing files are skipped / git pull). You **must name packs**.

## Restart (no one at the keyboard)

Put this script in the template **initialization / start hook so it runs before ComfyUI**. First boot: Comfy is not up yet → step 5 is a no-op → template starts Comfy once, with custom nodes already installed.

If you re-run `init.sh` later and Comfy **is** up, the script:

1. `supervisorctl restart comfyui` when that service exists (ai-dock-style images).
2. Otherwise stops `…/ComfyUI/main.py` and relaunches it with the same command line (or `--listen 0.0.0.0 --port 8188`).

Do **not** kill Comfy yourself. Do not rely on the web UI “restart”. Killing `main.py` on some start.sh templates can make the entrypoint think Comfy crashed; that is why init prefers “not running → leave it for the template”.

## Packs

```bash
bash init.sh krea
bash init.sh krea flux
bash init.sh zimage krea ltx
```

| Pack | Job | Workflow files (placeholders) |
|---|---|---|
| `krea` | text-to-image | `text_to_image_krea_2_turbo.json` |
| `zimage` | text-to-image | `text_to_image_z_image_turbo.json` |
| `flux` | image-to-image | `image_to_image_flux_kontext.json` |
| `ltx` | text-to-video **and** image-to-video | `text_to_video_ltx_2.3.json`, `image_to_video_ltx_2.3.json` |

Krea and Z-Image are **not** i2i. i2i is Flux Kontext only. `ltx` installs both video graphs from one pack (same weights).

`WORKFLOWS=krea,flux` is the same as positional packs.

## Setup on RunPod

```bash
set -euo pipefail
git clone --depth 1 <repo-url> /workspace/runpod-comfyui
bash /workspace/runpod-comfyui/init.sh krea flux
```

Template init must run **before** Comfy’s `main.py`.
Run: `bash /workspace/runpod-comfyui/init.sh krea`.

Optional env: `COMFYUI_PATH`, `WORKFLOWS=krea,zimage`.

## Flags

```bash
bash init.sh --list
bash init.sh krea --dry-run
```

| Flag | Meaning |
|---|---|
| positional / `-w` | Pack to install. |
| `--all` | Every pack. |
| `--list` | Print packs. |
| `--comfyui <path>` | Else `$COMFYUI_PATH` or `/workspace/ComfyUI`. |
| `--dry-run` | Print actions. |

## Replacing placeholder graphs

Overwrite the same files in `workflows/` (names in `packs.txt`). Re-run `init.sh krea` (etc.) to copy them onto the pod.
