# Runpod ComfyUI

Per-workflow shell scripts for ComfyUI on RunPod.

Repo on pod: `/workspace/custom-setup`

**Local model filenames:** lowercase, underscore-separated. Workflow JSON must match those names.

Two supported templates:

| Template | Image | ComfyUI | Models | Setup |
| -------- | ----- | ------- | ------ | ----- |
| **PyTorch** (full packs) | `runpod/pytorch:1.3.3-cu1281-torch291-ubuntu2404` | `/workspace/comfyui` | `/workspace/models/` | `scripts/comfyui/setup.sh` + `scripts/packs/*.sh` |
| **RunPod ComfyUI** (Krea + MiniMax) | `runpod/comfyui:1.3.3-comfyuiv0.30.0-cuda12.8` | `/workspace/runpod-slim/ComfyUI` | `ComfyUI/models/` | `scripts/custom-setup.sh` |

Expose port **8188** (ComfyUI). FileBrowser (**8080**) applies to the PyTorch path below.

## PyTorch template

ComfyUI: `/workspace/comfyui` · Models: `/workspace/models/`

Dev Mode is enabled automatically by `comfyui/setup.sh`.

### One-time setup

Run once per volume (persists under `/workspace`):

```bash
git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/custom-setup
bash /workspace/custom-setup/scripts/cleanup.sh

bash /workspace/custom-setup/scripts/comfyui/setup.sh
```

`cleanup.sh` removes `.git`, `.gitignore`, `README.md`, `SOURCE.md`, and `AGENTS.md`.

`setup.sh` clones ComfyUI, installs ComfyUI-GGUF + ComfyUI-Manager, and points ComfyUI at `/workspace/models` via `extra_model_paths.yaml` (no symlinks). Input/output use `/workspace/input` and `/workspace/output` via launch args. Dev Mode is enabled automatically.

Override ComfyUI version: `COMFYUI_REF=v0.37.0 bash /workspace/custom-setup/scripts/comfyui/setup.sh`

After the first start, open ComfyUI Manager and confirm **ComfyUI-GGUF** is installed correctly (GGUF workflows need it). If it shows missing dependencies or failed install, use Manager's **Try fix** button on that node.

### Start / stop
After a pod restart:

```bash
bash /workspace/custom-setup/scripts/comfyui/start.sh
bash /workspace/custom-setup/scripts/comfyui/stop.sh
```

## FileBrowser

Web file manager for `/workspace` (models, input, output). Port **8080**. `setup.sh` uses the image binary if present, otherwise installs **linux-amd64** to `/workspace/bin/filebrowser`.

### One-time setup

Run once per volume:

```bash
bash /workspace/custom-setup/scripts/filebrowser/setup.sh
```

Login: `admin` / `AdminAdmin#123` (or set `FILEBROWSER_PASSWORD` before setup). Config persists at `/workspace/filebrowser.db`.

### Start / stop

After a pod restart:

```bash
bash /workspace/custom-setup/scripts/filebrowser/start.sh
bash /workspace/custom-setup/scripts/filebrowser/stop.sh
```

## RunPod ComfyUI template

Image: **`runpod/comfyui:1.3.3-comfyuiv0.30.0-cuda12.8`** (ComfyUI **v0.30.0**, CUDA 12.8).

ComfyUI: `/workspace/runpod-slim/ComfyUI` · Models: `/workspace/runpod-slim/ComfyUI/models/`

Use `scripts/custom-setup.sh` instead of `comfyui/setup.sh` and the pack scripts. This path currently covers **Krea 2** and **MiniMax H3** only (models + `comfyui-krea2edit` for Krea i2i).

One-time on the pod (clone repo, run setup, then remove the repo):

```bash
git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/custom-setup
bash /workspace/custom-setup/scripts/custom-setup.sh
rm -rf /workspace/custom-setup
```

`custom-setup.sh` clones **[comfyui-krea2edit](https://github.com/lbouaraba/comfyui-krea2edit)** (required for Krea 2 i2i) and downloads Krea 2 + MiniMax H3 weights into `/workspace/runpod-slim/ComfyUI/models/` (UNET checkpoints in **`models/unet/`**, same as ComfyUI v0.30).

Upload workflows manually in ComfyUI (or into `/workspace/runpod-slim/ComfyUI/user/default/workflows/`). Files in this repo: `text_to_image_krea_2.json`, `image_to_image_krea_2.json`, `text_to_video_minimax_h3.json`, `image_to_video_minimax_h3.json`.

After ComfyUI is running, enable **Dev mode** in the UI: open **Settings** (gear icon) → turn on **Dev mode** → save/apply. Dev mode exposes workflow model metadata (download links on loader nodes) and subgraph editing; the PyTorch path enables it in `setup.sh`, this template does not unless you toggle it here.

Restart ComfyUI once after `custom-setup.sh` so the new custom node loads.

## Packs (PyTorch template only)

Run once per workflow (downloads models, copies workflow JSON):

```bash
bash /workspace/custom-setup/scripts/packs/krea.sh
```

Each pack script copies workflow JSON into ComfyUI's user folder and curls models into `/workspace/models/` (skips existing files; resumes via `.part`).

| Script | Mode | Workflow(s) |
| ------------------- | -------- | ----------------------------------------------------------- |
| `packs/krea.sh` | t2i, i2i | `text_to_image_krea_2.json`, `image_to_image_krea_2.json` |
| `packs/zimage.sh` | t2i | `text_to_image_z_image_turbo.json` |
| `packs/flux.sh` | i2i | `image_to_image_flux_1_kontext_dev.json` |
| `packs/minimax.sh` | t2v, i2v | `text_to_video_minimax_h3.json`, `image_to_video_minimax_h3.json` |
| `packs/qwen.sh` | i2i | `image_to_image_qwen_image_edit_2511.json` |

## Repository layout

```
custom-setup/
  config/extra_model_paths.yaml
  scripts/
    common.sh
    cleanup.sh
    custom-setup.sh
    comfyui/
      setup.sh
      start.sh
      stop.sh
    filebrowser/
      setup.sh
      start.sh
      stop.sh
    packs/
      krea.sh
      zimage.sh
      flux.sh
      minimax.sh
      qwen.sh
  workflows/
```