#!/usr/bin/env bash
# RunPod ComfyUI image runpod/comfyui:1.3.3-comfyuiv0.30.0-cuda12.8
# Krea 2 + MiniMax H3 models and comfyui-krea2edit (Krea i2i).
# ComfyUI: /workspace/runpod-slim/ComfyUI
# Run: bash /workspace/custom-setup/scripts/custom-setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

COMFYUI=/workspace/runpod-slim/ComfyUI
MODELS=$COMFYUI/models
KREA2EDIT=$COMFYUI/custom_nodes/comfyui-krea2edit

command -v git >/dev/null 2>&1 || { echo "error: git is required" >&2; exit 1; }

mkdir -p "$COMFYUI/custom_nodes"

if [[ -d "$KREA2EDIT" ]]; then
  echo "skip $KREA2EDIT"
else
  git clone --depth 1 https://github.com/lbouaraba/comfyui-krea2edit.git "$KREA2EDIT"
  echo "ok $KREA2EDIT"
fi

mkdir -p "$MODELS/diffusion_models"
mkdir -p "$MODELS/text_encoders"
mkdir -p "$MODELS/vae"
mkdir -p "$MODELS/loras"

# Krea 2
fetch "$MODELS/diffusion_models/krea2_turbo_fp8_scaled.safetensors" \
  https://huggingface.co/Comfy-Org/Krea-2/resolve/main/diffusion_models/krea2_turbo_fp8_scaled.safetensors

fetch "$MODELS/text_encoders/qwen3vl_4b_fp8_scaled.safetensors" \
  https://huggingface.co/Comfy-Org/Krea-2/resolve/main/text_encoders/qwen3vl_4b_fp8_scaled.safetensors

fetch "$MODELS/vae/qwen_image_vae.safetensors" \
  https://huggingface.co/Comfy-Org/Krea-2/resolve/main/vae/qwen_image_vae.safetensors

fetch "$MODELS/loras/krea2_filterbypass3.safetensors" \
  https://huggingface.co/uzumix/krea2filterbypass3.safetensors/resolve/main/krea2filterbypass3.safetensors

fetch "$MODELS/loras/krea2_realism_engine_v2.safetensors" \
  https://huggingface.co/uzumix/realism_engine_krea2_v2/resolve/main/realism_engine_krea2_v2.safetensors

fetch "$MODELS/loras/krea2_realism_v2.safetensors" \
  https://huggingface.co/RudySen/Krea2-realism-V2/resolve/main/Krea2-realism-V2.safetensors

fetch "$MODELS/loras/krea2_identity_edit_v1_2.safetensors" \
  https://huggingface.co/conradlocke/krea2-identity-edit/resolve/main/krea2_identity_edit_v1_2.safetensors

# MiniMax H3
fetch "$MODELS/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors" \
  https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors

fetch "$MODELS/loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors" \
  https://huggingface.co/lightx2v/Minimax-h3-Turbo/resolve/main/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors

fetch "$MODELS/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors" \
  https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors

fetch "$MODELS/vae/minimax_h3_video_vae_fp16.safetensors" \
  https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_video_vae_fp16.safetensors

fetch "$MODELS/vae/minimax_h3_audio_vae_fp32.safetensors" \
  https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors

echo "Done: comfyui-krea2edit + Krea 2 + MiniMax H3 models in $MODELS"

echo "Restart ComfyUI, then enable Dev mode in Settings."
