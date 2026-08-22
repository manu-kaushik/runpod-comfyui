#!/usr/bin/env bash

# Z-Image Turbo — copy workflow + download models. Run from pod terminal.

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

cp -f "$REPO/workflows/text_to_image_z_image_turbo.json" "$WF/"

fetch "$MODELS/unet/z_image_turbo_q4_k_m.gguf" \
    "https://huggingface.co/unsloth/Z-Image-Turbo-GGUF/resolve/main/z-image-turbo-Q4_K_M.gguf"

fetch "$MODELS/text_encoders/qwen_3_4b.safetensors" \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"

fetch "$MODELS/vae/ae.safetensors" \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"

echo "Successfully setup Z-Image Turbo."
