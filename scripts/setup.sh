#!/usr/bin/env bash

# One-time pod setup: workspace dirs, ComfyUI model paths, input/output symlinks.
# Seeds /workspace/workflows/ from repo when a file is not already present.

set -euo pipefail

source "$(dirname "$0")/common.sh"

mkdir -p /workspace/models/{checkpoints,diffusion_models,text_encoders,vae,loras,clip}
mkdir -p "$WF_SRC" /workspace/input /workspace/output "$WF"

if [[ -d "$REPO/workflows" ]]; then
    for f in "$REPO/workflows/"*.json; do
        [[ -f "$f" ]] || continue
        dest="$WF_SRC/$(basename "$f")"
        if [[ ! -f "$dest" ]]; then
            cp "$f" "$dest"
            echo "seed $dest"
        fi
    done
fi

cp -f "$REPO/config/extra_model_paths.yaml" "$COMFYUI/extra_model_paths.yaml"
echo "installed $COMFYUI/extra_model_paths.yaml"

for dir in input output; do
    target="/workspace/$dir"
    link="$COMFYUI/$dir"
    if [[ -e "$link" && ! -L "$link" ]]; then
        rm -rf "$link"
    fi
    ln -sfn "$target" "$link"
    echo "link $link -> $target"
done

echo "Setup complete. Restart ComfyUI if it is running."
