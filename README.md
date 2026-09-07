# Runpod ComfyUI

Per-workflow shell scripts for comfyui runpod setup.

ComfyUI: `/workspace/runpod-slim/ComfyUI`

Repo: `/workspace/comfyui-packs`

**(REQUIRED)** Install **ComfyUI-GGUF** and **Dev Mode** from the ComfyUI GUI.

## Workspace layout (persistent on `/workspace`)

```

/workspace/models/      # model weights (ComfyUI reads via extra_model_paths.yaml)

/workspace/workflows/   # source of truth for workflow JSON

/workspace/input/       # ComfyUI input (symlinked)

/workspace/output/      # ComfyUI output (symlinked)

```

Repo ships workflow templates in `comfyui-packs/workflows/`; `setup.sh` seeds them into `/workspace/workflows/` when missing.

**Local model filenames:** lowercase, underscore-separated. Workflow JSON must match those names.

## On the pod terminal

```bash

git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/comfyui-packs

bash /workspace/comfyui-packs/scripts/setup.sh   # once per pod

bash /workspace/comfyui-packs/scripts/krea.sh



# Remove cloned repo

rm -rf /workspace/comfyui-packs

```

`setup.sh` creates workspace dirs, installs `extra_model_paths.yaml`, symlinks input/output, and seeds `/workspace/workflows/`.

Each pack script copies from `/workspace/workflows/` into ComfyUI's user folder and curls models into `/workspace/models/` (skips existing files; resumes via `.part`).

| Script | Mode | Workflow(s) |

| ----------- | ---- | ----------------------------------------------------------- |

| `krea.sh` | t2i | `text_to_image_krea_2_turbo.json` |

| `zimage.sh` | t2i | `text_to_image_z_image_turbo.json` |

| `flux.sh` | i2i | `image_to_image_flux_1_kontext_dev.json` |

| `ltx.sh` | t2v, i2v | `text_to_video_ltx_2_3_dev.json`, `image_to_video_ltx_2_3_dev.json` |

| `minimax.sh`| t2v, i2v | `text_to_video_minimax_h3.json`, `image_to_video_minimax_h3.json` |

| `qwen.sh` | i2i | `image_to_image_qwen_image_edit_2511.json` |

Run `setup.sh` once, then run a pack script after ComfyUI is up. Restart ComfyUI after the first `setup.sh`.
