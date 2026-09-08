#!/usr/bin/env bash

# MiniMax H3 t2v + i2v — copy workflows + download models. Run from pod terminal.

set -euo pipefail

source "$(dirname "$0")/../common.sh"

mkdir -p "$WF"

cp -f "$REPO/workflows/text_to_video_minimax_h3.json" "$WF/"
cp -f "$REPO/workflows/image_to_video_minimax_h3.json" "$WF/"

fetch "$MODELS/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors" \
    "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors"

fetch "$MODELS/loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors" \
    "https://huggingface.co/lightx2v/Minimax-h3-Turbo/resolve/main/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors"

fetch "$MODELS/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors" \
    "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors"

fetch "$MODELS/vae/minimax_h3_video_vae_fp16.safetensors" \
    "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_video_vae_fp16.safetensors"

fetch "$MODELS/vae/minimax_h3_audio_vae_fp32.safetensors" \
    "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors"

echo "Successfully setup MiniMax H3."
