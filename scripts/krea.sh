#!/usr/bin/env bash

# Krea 2 Turbo — copy workflow + download models. Run from pod terminal.

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

cp -f "$REPO/workflows/text_to_image_krea_2_turbo.json" "$WF/"

fetch "$MODELS/diffusion_models/krea2_turbo_q4_k_m.gguf" \
    "https://huggingface.co/vantagewithai/Krea-2-Turbo-GGUF/resolve/main/krea2_turbo-Q4_K_M.gguf"

fetch "$MODELS/text_encoders/qwen3vl_4b_fp8_scaled.safetensors" \
    "https://huggingface.co/Comfy-Org/Krea-2/resolve/main/text_encoders/qwen3vl_4b_fp8_scaled.safetensors"

fetch "$MODELS/vae/qwen_image_vae.safetensors" \
    "https://huggingface.co/Comfy-Org/Krea-2/resolve/main/vae/qwen_image_vae.safetensors"

fetch "$MODELS/loras/krea2_realism_v2.safetensors" \
    "https://huggingface.co/RudySen/Krea2-realism-V2/resolve/main/Krea2-realism-V2.safetensors"

echo "Successfully setup Krea 2 Turbo."
