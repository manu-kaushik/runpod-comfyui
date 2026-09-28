#!/usr/bin/env bash

# Krea 2 — copy workflows + download models. Run from pod terminal.

set -euo pipefail

source "$(dirname "$0")/../common.sh"

mkdir -p "$WF"

cp -f "$REPO/workflows/text_to_image_krea_2.json" "$WF/"
cp -f "$REPO/workflows/image_to_image_krea_2.json" "$WF/"

fetch "$MODELS/diffusion_models/krea2_turbo_fp8_scaled.safetensors" \
    "https://huggingface.co/Comfy-Org/Krea-2/resolve/main/diffusion_models/krea2_turbo_fp8_scaled.safetensors"

fetch "$MODELS/text_encoders/qwen3vl_4b_fp8_scaled.safetensors" \
    "https://huggingface.co/Comfy-Org/Krea-2/resolve/main/text_encoders/qwen3vl_4b_fp8_scaled.safetensors"

fetch "$MODELS/vae/qwen_image_vae.safetensors" \
    "https://huggingface.co/Comfy-Org/Krea-2/resolve/main/vae/qwen_image_vae.safetensors"

fetch "$MODELS/loras/krea2_filterbypass3.safetensors" \
    "https://huggingface.co/uzumix/krea2filterbypass3.safetensors/resolve/main/krea2filterbypass3.safetensors"

fetch "$MODELS/loras/krea2_realism_engine_v2.safetensors" \
    "https://huggingface.co/uzumix/realism_engine_krea2_v2/resolve/main/realism_engine_krea2_v2.safetensors"

fetch "$MODELS/loras/krea2_realism_v2.safetensors" \
    "https://huggingface.co/RudySen/Krea2-realism-V2/resolve/main/Krea2-realism-V2.safetensors"

fetch "$MODELS/loras/krea2_identity_edit_v1_2.safetensors" \
    "https://huggingface.co/conradlocke/krea2-identity-edit/resolve/main/krea2_identity_edit_v1_2.safetensors"

echo "Successfully setup Krea 2."
