# Runpod ComfyUI

Per-workflow shell scripts for ComfyUI on RunPod.

ComfyUI: `/workspace/comfyui`  

Models: `/workspace/models/`

Repo: `/workspace/comfyui-packs`

Use a **RunPod PyTorch** pod (e.g. `runpod/pytorch:1.0.2-cu1281-torch271-ubuntu2404`), expose port **8188**, then run `install-comfyui.sh` once (Dev Mode is enabled automatically).

```

comfyui-packs/

  config/extra_model_paths.yaml

  scripts/

    install-comfyui.sh
    start-comfyui.sh

    krea.sh

    zimage.sh

    flux.sh

    ltx.sh

    minimax.sh

    qwen.sh

  workflows/

```

**Local model filenames:** lowercase, underscore-separated. Workflow JSON must match those names.

## On the pod terminal

```bash

git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/comfyui-packs

bash /workspace/comfyui-packs/scripts/install-comfyui.sh
bash /workspace/comfyui-packs/scripts/start-comfyui.sh

bash /workspace/comfyui-packs/scripts/krea.sh

```

`install-comfyui.sh` clones ComfyUI, installs ComfyUI-GGUF + ComfyUI-Manager, and points ComfyUI at `/workspace/models` via `extra_model_paths.yaml` (no symlinks). Input/output use `/workspace/input` and `/workspace/output` via launch args.

Each pack script copies workflow JSON into ComfyUI's user folder and curls models into `/workspace/models/` (skips existing files; resumes via `.part`).

| Script | Mode | Workflow(s) |

| ------------------- | -------- | ----------------------------------------------------------- |

| `install-comfyui.sh`| setup    | ComfyUI + GGUF + Manager                                    |
| `start-comfyui.sh`  | start    | Run ComfyUI in background on port 8188                      |

| `krea.sh` | t2i | `text_to_image_krea_2_turbo.json` |

| `zimage.sh` | t2i | `text_to_image_z_image_turbo.json` |

| `flux.sh` | i2i | `image_to_image_flux_1_kontext_dev.json` |

| `ltx.sh` | t2v, i2v | `text_to_video_ltx_2_3_dev.json`, `image_to_video_ltx_2_3_dev.json` |

| `minimax.sh` | t2v, i2v | `text_to_video_minimax_h3.json`, `image_to_video_minimax_h3.json` |

| `qwen.sh` | i2i | `image_to_image_qwen_image_edit_2511.json` |

Override ComfyUI version: `COMFYUI_REF=v0.3.66 bash /workspace/comfyui-packs/scripts/install-comfyui.sh`
