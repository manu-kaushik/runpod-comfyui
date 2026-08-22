#!/usr/bin/env bash

# FLUX Kontext i2i — copy workflow + download models. Run from pod terminal.

set -euo pipefail

COMFYUI=/workspace/runpod-slim/ComfyUI
REPO=/workspace/runpod-comfyui
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

cp -f "$REPO/workflows/image_to_image_flux_kontext.json" "$WF/"

fetch "$MODELS/diffusion_models/flux1_kontext_dev_q4_k_m.gguf" \
    "https://huggingface.co/QuantStack/FLUX.1-Kontext-dev-GGUF/resolve/main/flux1-kontext-dev-Q4_K_M.gguf"

fetch "$MODELS/vae/ae.safetensors" \
    "https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors"

fetch "$MODELS/text_encoders/clip_l.safetensors" \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"

fetch "$MODELS/text_encoders/t5xxl_fp16.safetensors" \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"

echo "Successfully setup FLUX Kontext."
