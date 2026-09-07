#!/usr/bin/env bash

# Install ComfyUI on a RunPod PyTorch pod. Run once before pack scripts.
#   COMFYUI_REF=v0.34.0 bash install-comfyui.sh   (default tag)
#   bash install-comfyui.sh --fresh               (re-clone ComfyUI)

set -euo pipefail

COMFYUI_REF="${COMFYUI_REF:-v0.34.0}"
FRESH=false
for arg in "$@"; do
    [[ "$arg" == --fresh ]] && FRESH=true
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
COMFYUI=/workspace/comfyui
VENV="$COMFYUI/.venv"
ARGS_FILE="$COMFYUI/comfyui_args.txt"

die() {
    echo "error: $*" >&2
    exit 1
}

command -v git >/dev/null 2>&1 || die "git is required"
command -v curl >/dev/null 2>&1 || die "curl is required"
python3 -c "import torch; assert torch.cuda.is_available()" 2>/dev/null \
    || die "CUDA torch not found — use a RunPod PyTorch template (e.g. runpod/pytorch:1.0.2-cu1281-torch271-ubuntu2404)"

mkdir -p /workspace/models/{checkpoints,diffusion_models,text_encoders,vae,loras,clip}
mkdir -p /workspace/input /workspace/output

if [[ "$FRESH" == true && -d "$COMFYUI" ]]; then
    rm -rf "$COMFYUI"
fi

if [[ ! -f "$COMFYUI/main.py" ]]; then
    echo "cloning ComfyUI $COMFYUI_REF"
    git clone --depth 1 --branch "$COMFYUI_REF" https://github.com/Comfy-Org/ComfyUI.git "$COMFYUI"
else
    echo "skip clone ($COMFYUI exists)"
fi

if [[ ! -d "$VENV" ]]; then
    python3 -m venv --system-site-packages "$VENV"
fi
# shellcheck disable=SC1091
source "$VENV/bin/activate"

python -c "import torch; print('torch', torch.__version__, 'cuda', torch.version.cuda)"

pip install -U pip wheel
# Keep the base image torch; install everything else ComfyUI needs.
grep -Ev '^(torch|torchvision|torchaudio)([^a-zA-Z]|$)' "$COMFYUI/requirements.txt" \
    > /tmp/comfyui-requirements-no-torch.txt
pip install -r /tmp/comfyui-requirements-no-torch.txt

mkdir -p "$COMFYUI/custom_nodes"
clone_node() {
    local url="$1" name="$2"
    if [[ -d "$COMFYUI/custom_nodes/$name" ]]; then
        echo "skip node $name"
    else
        git clone --depth 1 "$url" "$COMFYUI/custom_nodes/$name"
        echo "ok node $name"
    fi
}

clone_node https://github.com/city96/ComfyUI-GGUF.git ComfyUI-GGUF
clone_node https://github.com/ltdrdata/ComfyUI-Manager.git ComfyUI-Manager

cp -f "$REPO/config/extra_model_paths.yaml" "$COMFYUI/extra_model_paths.yaml"
mkdir -p "$COMFYUI/user/default/workflows"

python <<PY
import json
from pathlib import Path

p = Path("$COMFYUI/user/default/comfy.settings.json")
data = json.loads(p.read_text()) if p.exists() else {}
data["Comfy.DevMode"] = True
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"ok {p} (Comfy.DevMode=true)")
PY

cat > "$ARGS_FILE" <<'EOF'
--listen
0.0.0.0
--port
8188
--enable-cors-header
--input-directory
/workspace/input
--output-directory
/workspace/output
EOF

echo ""
echo "ComfyUI installed at $COMFYUI"
echo "Models path: /workspace/models (via extra_model_paths.yaml)"
echo ""
echo "Start ComfyUI:"
echo "  bash $REPO/scripts/start-comfyui.sh"
echo ""
echo "Then run a pack script."
