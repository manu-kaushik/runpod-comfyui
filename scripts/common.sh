# Shared paths and fetch helper for pack scripts. Source from scripts/*.sh.

COMFYUI=/workspace/runpod-slim/ComfyUI
REPO=/workspace/comfyui-packs
MODELS=/workspace/models
WF_SRC=/workspace/workflows
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
