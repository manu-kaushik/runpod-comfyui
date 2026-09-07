#!/usr/bin/env bash

# Z-Image Turbo — copy workflow + download models. Run from pod terminal.

set -euo pipefail

source "$(dirname "$0")/common.sh"

mkdir -p "$WF"

cp -f "$WF_SRC/text_to_image_z_image_turbo.json" "$WF/"

fetch "$MODELS/diffusion_models/z_image_turbo_q4_k_m.gguf" \
    "https://huggingface.co/unsloth/Z-Image-Turbo-GGUF/resolve/main/z-image-turbo-Q4_K_M.gguf"

fetch "$MODELS/text_encoders/qwen_3_4b.safetensors" \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"

fetch "$MODELS/vae/ae.safetensors" \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"

echo "Successfully setup Z-Image Turbo."
