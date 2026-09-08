# Runpod ComfyUI

Per-workflow shell scripts for ComfyUI on RunPod.

ComfyUI: `/workspace/comfyui`

Models: `/workspace/models/`

Repo: `/workspace/custom-setup`

Use a **RunPod PyTorch** pod (e.g. `runpod/pytorch:1.0.2-cu1281-torch271-ubuntu2404`), expose ports **8188** (ComfyUI) and **8080** (FileBrowser, optional), then run ComfyUI setup once (Dev Mode is enabled automatically).

**Local model filenames:** lowercase, underscore-separated. Workflow JSON must match those names.

## ComfyUI
### One-time setup

Run once per volume (persists under `/workspace`):

```bash
git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/custom-setup

bash /workspace/custom-setup/scripts/comfyui/setup.sh
```

`setup.sh` clones ComfyUI, installs ComfyUI-GGUF + ComfyUI-Manager, and points ComfyUI at `/workspace/models` via `extra_model_paths.yaml` (no symlinks). Input/output use `/workspace/input` and `/workspace/output` via launch args. Dev Mode is enabled automatically.

Override ComfyUI version: `COMFYUI_REF=v0.34.0 bash /workspace/custom-setup/scripts/comfyui/setup.sh`

After the first start, open ComfyUI Manager and confirm **ComfyUI-GGUF** is installed correctly (GGUF workflows need it). If it shows missing dependencies or failed install, use Manager's **Try fix** button on that node.

### Start / stop
After a pod restart:

```bash
bash /workspace/custom-setup/scripts/comfyui/start.sh
bash /workspace/custom-setup/scripts/comfyui/stop.sh
```

## FileBrowser

Web file manager for `/workspace` (models, input, output). Port **8080**. The `filebrowser` binary is included on RunPod PyTorch images.

### One-time setup

Run once per volume:

```bash
bash /workspace/custom-setup/scripts/filebrowser/setup.sh
```

Login: `admin` / `adminadmin12` (or set `FILEBROWSER_PASSWORD` before setup). Config persists at `/workspace/filebrowser.db`.

### Start / stop

After a pod restart:

```bash
bash /workspace/custom-setup/scripts/filebrowser/start.sh
bash /workspace/custom-setup/scripts/filebrowser/stop.sh
```

## Packs

Run once per workflow (downloads models, copies workflow JSON):

```bash
bash /workspace/custom-setup/scripts/packs/krea.sh
```

Each pack script copies workflow JSON into ComfyUI's user folder and curls models into `/workspace/models/` (skips existing files; resumes via `.part`).

| Script | Mode | Workflow(s) |
| ------------------- | -------- | ----------------------------------------------------------- |
| `packs/krea.sh` | t2i | `text_to_image_krea_2_turbo.json` |
| `packs/zimage.sh` | t2i | `text_to_image_z_image_turbo.json` |
| `packs/flux.sh` | i2i | `image_to_image_flux_1_kontext_dev.json` |
| `packs/ltx.sh` | t2v, i2v | `text_to_video_ltx_2_3_dev.json`, `image_to_video_ltx_2_3_dev.json` |
| `packs/minimax.sh` | t2v, i2v | `text_to_video_minimax_h3.json`, `image_to_video_minimax_h3.json` |
| `packs/qwen.sh` | i2i | `image_to_image_qwen_image_edit_2511.json` |

## Repository layout

```
custom-setup/
  config/extra_model_paths.yaml
  scripts/
    common.sh
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
      ltx.sh
      minimax.sh
      qwen.sh
  workflows/
```