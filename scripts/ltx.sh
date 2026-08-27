#!/usr/bin/env bash

# LTX 2.3 t2v + i2v — copy workflows + download models. Run from pod terminal.

set -euo pipefail

COMFYUI=/workspace/runpod-slim/ComfyUI
REPO=/workspace/comfyui-packs
MODELS=$COMFYUI/models
WF=$COMFYUI/user/default/workflows

fetch() {
    local dest="$1" url="$2"

    if [[ -f "$dest" && -s "$dest" ]]; then
        echo "skip $dest"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    curl -fL --retry 3 --retry-delay 2 --continue-at - -o "${dest}.part" "$url"
    mv -f "${dest}.part" "$dest"
    echo "ok $dest"
}


mkdir -p "$WF"

cp -f "$REPO/workflows/text_to_video_ltx_2_3_dev.json" "$WF/"
cp -f "$REPO/workflows/image_to_video_ltx_2_3_dev.json" "$WF/"

fetch "$MODELS/diffusion_models/ltx_2_3_22b_dev_q4_k_m.gguf" \
    "https://huggingface.co/unsloth/LTX-2.3-GGUF/resolve/main/ltx-2.3-22b-dev-Q4_K_M.gguf"

fetch "$MODELS/text_encoders/gemma_3_12b_it_fp4_mixed.safetensors" \
    "https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors"

fetch "$MODELS/vae/ltx_2_3_22b_dev_video_vae.safetensors" \
    "https://huggingface.co/unsloth/LTX-2.3-GGUF/resolve/main/vae/ltx-2.3-22b-dev_video_vae.safetensors"

fetch "$MODELS/checkpoints/ltx_2_3_22b_dev_audio_vae.safetensors" \
    "https://huggingface.co/unsloth/LTX-2.3-GGUF/resolve/main/vae/ltx-2.3-22b-dev_audio_vae.safetensors"

echo "Successfully setup LTX 2.3."
