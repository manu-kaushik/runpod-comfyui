#!/usr/bin/env bash

# Qwen Image Edit 2511 i2i — copy workflow + download models. Run from pod terminal.

set -euo pipefail

source "$(dirname "$0")/common.sh"

mkdir -p "$WF"

cp -f "$REPO/workflows/image_to_image_qwen_image_edit_2511.json" "$WF/"

fetch "$MODELS/diffusion_models/qwen_image_edit_2511_q3_k_m.gguf" \
    "https://huggingface.co/unsloth/Qwen-Image-Edit-2511-GGUF/resolve/main/qwen-image-edit-2511-Q3_K_M.gguf"

fetch "$MODELS/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" \
    "https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"

fetch "$MODELS/vae/qwen_image_vae.safetensors" \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors"

echo "Successfully setup Qwen Image Edit 2511."
