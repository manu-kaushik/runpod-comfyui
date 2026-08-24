# Runpod ComfyUI

Per-workflow shell scripts for comfyui runpod setup.

ComfyUI: `/workspace/runpod-slim/ComfyUI`  
Repo: `/workspace/runpod-comfyui`

**(REQUIRED)** Install **ComfyUI-GGUF** and **Dev Mode** from the ComfyUI GUI.

```
runpod-comfyui/
  scripts/
    krea.sh
    zimage.sh
    flux.sh
    ltx.sh
  workflows/
```

**Local model filenames:** lowercase, underscore-separated. Workflow JSON must match those names.

## On the pod terminal

```bash
git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/runpod-comfyui
bash /workspace/runpod-comfyui/scripts/krea.sh
```

Each script copies workflow JSON and curls models (skips existing files; resumes via `.part`).

| Script      | Workflow(s)                                                 |
| ----------- | ----------------------------------------------------------- |
| `krea.sh`   | `text_to_image_krea_2_turbo.json`                           |
| `zimage.sh` | `text_to_image_z_image_turbo.json`                          |
| `flux.sh`   | `image_to_image_flux_1_kontext_dev.json`                    |
| `ltx.sh`    | models only (workflows pending)                             |

Run the pack script from the terminal after ComfyUI is up.
