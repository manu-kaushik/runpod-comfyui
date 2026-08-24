#!/usr/bin/env bash

# LTX 2.3 — download models. Run from pod terminal. (Workflows pending.)

set -euo pipefail

COMFYUI=/workspace/runpod-slim/ComfyUI
MODELS=$COMFYUI/models

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

fetch "$MODELS/checkpoints/ltx_2_3_22b_dev_q4_k_m.gguf" \
    "https://huggingface.co/unsloth/LTX-2.3-GGUF/resolve/main/ltx-2.3-22b-dev-Q4_K_M.gguf"

fetch "$MODELS/loras/ltx_2_3_22b_distilled_1_1_lora_dynamic_fro09_avg_rank_111_bf16.safetensors" \
    "https://huggingface.co/Comfy-Org/ltx-2.3/resolve/main/split_files/loras/ltx_2.3_22b_distilled_1.1_lora_dynamic_fro09_avg_rank_111_bf16.safetensors"

fetch "$MODELS/loras/gemma_3_12b_it_abliterated_lora_rank64_bf16.safetensors" \
    "https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/loras/gemma-3-12b-it-abliterated_lora_rank64_bf16.safetensors"

fetch "$MODELS/latent_upscale_models/ltx_2_3_spatial_upscaler_x2_1_1.safetensors" \
    "https://huggingface.co/Lightricks/LTX-2.3/resolve/main/ltx-2.3-spatial-upscaler-x2-1.1.safetensors"

fetch "$MODELS/text_encoders/gemma_3_12b_it_fp4_mixed.safetensors" \
    "https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors"

echo "Successfully setup LTX 2.3."
