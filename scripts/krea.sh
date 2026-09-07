#!/usr/bin/env bash

# Krea 2 Turbo — copy workflow + download models. Run from pod terminal.
#   --skip-diff  skip downloading the GGUF diffusion model

set -euo pipefail

SKIP_DIFFUSION_MODEL=false
for arg in "$@"; do
    [[ "$arg" == --skip-diff ]] && SKIP_DIFFUSION_MODEL=true
done

source "$(dirname "$0")/common.sh"

mkdir -p "$WF"

cp -f "$WF_SRC/text_to_image_krea_2_turbo.json" "$WF/"

if [[ "$SKIP_DIFFUSION_MODEL" != true ]]; then
    fetch "$MODELS/diffusion_models/krea2_turbo_q4_k_m.gguf" \
        "https://huggingface.co/vantagewithai/Krea-2-Turbo-GGUF/resolve/main/krea2_turbo-Q4_K_M.gguf"
else
    echo "skip diffusion model fetch (--skip-diff)"
fi

fetch "$MODELS/text_encoders/qwen3vl_4b_fp8_scaled.safetensors" \
    "https://huggingface.co/Comfy-Org/Krea-2/resolve/main/text_encoders/qwen3vl_4b_fp8_scaled.safetensors"

fetch "$MODELS/vae/qwen_image_vae.safetensors" \
    "https://huggingface.co/Comfy-Org/Krea-2/resolve/main/vae/qwen_image_vae.safetensors"

fetch "$MODELS/loras/krea2_realism_v2.safetensors" \
    "https://huggingface.co/RudySen/Krea2-realism-V2/resolve/main/Krea2-realism-V2.safetensors"

echo "Successfully setup Krea 2 Turbo."
