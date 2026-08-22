#!/usr/bin/env bash

# LTX 2.3 t2v + i2v — copy workflows + download models. Run from pod terminal.

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

cp -f "$REPO/workflows/text_to_video_ltx_2.3.json" "$WF/"
cp -f "$REPO/workflows/image_to_video_ltx_2.3.json" "$WF/"

fetch "$MODELS/diffusion_models/ltx_2_3_22b_dev_q4_k_m.gguf" \
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
