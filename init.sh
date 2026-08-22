#!/usr/bin/env bash
# RunPod / ComfyUI bootstrap: copy selected editor workflows and curl their models.
# See README.md in this folder.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${ROOT}/models.txt"
PACKS_FILE="${ROOT}/packs.txt"
WORKFLOWS_DIR="${ROOT}/workflows"

SELECTED=()
DO_ALL=0
LIST_ONLY=0
DRY_RUN=0
COMFYUI_PATH="${COMFYUI_PATH:-}"

GGUF_REPO="${GGUF_REPO:-https://github.com/city96/ComfyUI-GGUF.git}"

# pack_id -> comma-separated workflow stems (empty until final graphs)
declare -A PACK_WORKFLOWS=()
declare -A PACK_JOBS=()
# pack id or alias -> pack_id
declare -A PACK_LOOKUP=()
PACK_IDS=()

usage() {
    cat <<'EOF'
Usage: bash init.sh <pack> [<pack> ...]
       bash init.sh krea flux
       bash init.sh --all
       bash init.sh --list

Packs:
  krea      text-to-image (Krea 2 Turbo GGUF)
  zimage    text-to-image (Z-Image Turbo GGUF)
  flux      image-to-image (FLUX Kontext GGUF)
  ltx       text-to-video + image-to-video (LTX 2.3 GGUF)

Always:
  * clone/update custom_nodes/ComfyUI-GGUF and pip-install its requirements
  * set Comfy.DevMode in user/default/comfy.settings.json (API save, etc.)
  * copy this pack's placeholder workflows (same filenames when graphs are finalized)
  * curl this pack's models
  * restart ComfyUI if it is already running (so GGUF nodes load). If it is
    not running yet, the template starts it after this script.

Flags:
  -w, --workflow <pack>  Same as a positional pack. Repeatable.
  --all                  Every pack in packs.txt
  --list                 Print packs and exit
  --comfyui <path>       ComfyUI root (else $COMFYUI_PATH or common defaults)
  --dry-run              Print actions, write nothing
  -h, --help

Env:
  COMFYUI_PATH      ComfyUI root, e.g. /workspace/ComfyUI
  WORKFLOWS         Comma-separated packs (same as positional args)

RunPod template example:
  git clone --depth 1 https://github.com/manu-kaushik/runpod-comfyui /workspace/runpod-comfyui
  bash /workspace/runpod-comfyui/init.sh krea flux
EOF
}

log() { printf '%s\n' "$*"; }
warn() { printf 'warn: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

load_packs() {
    local pack aliases job workflows alias
    [[ -f "$PACKS_FILE" ]] || die "missing ${PACKS_FILE}"

    while IFS='|' read -r pack aliases job workflows || [[ -n "${pack:-}" ]]; do
        pack="$(trim "${pack:-}")"
        [[ -z "$pack" || "$pack" == \#* ]] && continue
        aliases="$(trim "${aliases:-}")"
        job="$(trim "${job:-}")"
        workflows="$(trim "${workflows:-}")"

        PACK_IDS+=("$pack")
        PACK_JOBS["$pack"]="$job"
        PACK_WORKFLOWS["$pack"]="$workflows"
        PACK_LOOKUP["$pack"]="$pack"

        if [[ -n "$aliases" ]]; then
            IFS=',' read -r -a alias_arr <<< "$aliases"
            for alias in "${alias_arr[@]}"; do
                alias="$(trim "$alias")"
                [[ -n "$alias" ]] && PACK_LOOKUP["$alias"]="$pack"
            done
        fi
    done < "$PACKS_FILE"
}

resolve_pack() {
    local name="$1"
    if [[ -n "${PACK_LOOKUP[$name]+x}" ]]; then
        printf '%s' "${PACK_LOOKUP[$name]}"
        return 0
    fi
    return 1
}

list_packs() {
    local pack aliases job workflows
    log "Packs:"
    printf '  %-8s  %-22s  %-10s  %s\n' "PACK" "ALIASES" "JOB" "WORKFLOWS"
    while IFS='|' read -r pack aliases job workflows || [[ -n "${pack:-}" ]]; do
        pack="$(trim "${pack:-}")"
        [[ -z "$pack" || "$pack" == \#* ]] && continue
        aliases="$(trim "${aliases:-}")"
        job="$(trim "${job:-}")"
        workflows="$(trim "${workflows:-}")"
        [[ -z "$aliases" ]] && aliases="—"
        [[ -z "$job" ]] && job="—"
        [[ -z "$workflows" ]] && workflows="(none)"
        printf '  %-8s  %-22s  %-10s  %s\n' "$pack" "$aliases" "$job" "$workflows"
    done < "$PACKS_FILE"
}

resolve_comfyui() {
    local candidate
    if [[ -n "$COMFYUI_PATH" ]]; then
        [[ -d "$COMFYUI_PATH" ]] || die "COMFYUI_PATH is not a directory: $COMFYUI_PATH"
        return 0
    fi
    for candidate in \
        /workspace/ComfyUI \
        /workspace/runpod-slim/ComfyUI \
        /ComfyUI \
        "${ROOT}/ComfyUI"; do
        if [[ -d "$candidate" ]]; then
            COMFYUI_PATH="$candidate"
            return 0
        fi
    done
    die "Could not find ComfyUI. Set --comfyui or COMFYUI_PATH."
}

workflows_dest() {
    local dest="${COMFYUI_PATH}/user/default/workflows"
    if [[ "$DRY_RUN" -eq 0 ]]; then
        mkdir -p "$dest"
    fi
    printf '%s' "$dest"
}

find_comfy_python() {
    local candidate
    for candidate in \
        "${COMFYUI_PATH}/venv/bin/python" \
        "${COMFYUI_PATH}/.venv/bin/python" \
        "${COMFYUI_PATH}/python_embeded/python" \
        /workspace/venv/bin/python; do
        if [[ -x "$candidate" ]]; then
            printf '%s' "$candidate"
            return 0
        fi
    done
    if command -v python3 >/dev/null 2>&1; then
        command -v python3
        return 0
    fi
    if command -v python >/dev/null 2>&1; then
        command -v python
        return 0
    fi
    return 1
}

install_comfy_gguf() {
    local dest="${COMFYUI_PATH}/custom_nodes/ComfyUI-GGUF"
    local py req

    log "Installing ComfyUI-GGUF → ${dest}"
    if [[ "$DRY_RUN" -eq 1 ]]; then
        if [[ -d "${dest}/.git" ]]; then
            log "  would git pull ${dest}"
        else
            log "  would git clone ${GGUF_REPO}"
        fi
        log "  would pip install -r requirements.txt"
        return 0
    fi

    mkdir -p "${COMFYUI_PATH}/custom_nodes"
    if [[ -d "${dest}/.git" ]]; then
        git -C "$dest" pull --ff-only
        log "  updated existing clone"
    elif [[ -d "$dest" ]]; then
        warn "${dest} exists but is not a git clone; leaving it"
    else
        git clone --depth 1 "$GGUF_REPO" "$dest"
        log "  cloned ComfyUI-GGUF"
    fi

    py="$(find_comfy_python)" || die "no python for ComfyUI-GGUF pip install"
    req="${dest}/requirements.txt"
    if [[ -f "$req" ]]; then
        "$py" -m pip install --upgrade -r "$req"
    else
        "$py" -m pip install --upgrade gguf
    fi
    log "  python: ${py}"
}

enable_dev_mode() {
    local settings="${COMFYUI_PATH}/user/default/comfy.settings.json"
    local py

    log "Enabling Comfy Dev Mode → ${settings}"
    if [[ "$DRY_RUN" -eq 1 ]]; then
        log "  would set Comfy.DevMode=true (API save, etc.)"
        return 0
    fi

    mkdir -p "$(dirname "$settings")"
    py="$(find_comfy_python)" || die "no python to write comfy.settings.json"
    SETTINGS_PATH="$settings" "$py" - <<'PY'
import json
import os

path = os.environ["SETTINGS_PATH"]
data = {}
if os.path.isfile(path):
    try:
        with open(path, encoding="utf-8") as handle:
            loaded = json.load(handle)
        if isinstance(loaded, dict):
            data = loaded
    except json.JSONDecodeError:
        pass
data["Comfy.DevMode"] = True
with open(path, "w", encoding="utf-8") as handle:
    json.dump(data, handle, indent=2)
    handle.write("\n")
PY
    log "  Comfy.DevMode=true"
}

comfy_main_pids() {
    pgrep -f "${COMFYUI_PATH}/main.py" 2>/dev/null || true
}

comfy_http_up() {
    curl -sf -o /dev/null --max-time 2 "http://127.0.0.1:8188/" 2>/dev/null
}

restart_comfyui() {
    local pid cmdline py

    log "Reloading ComfyUI so ComfyUI-GGUF is picked up"
    if [[ "$DRY_RUN" -eq 1 ]]; then
        log "  would restart ComfyUI only if it is already running"
        return 0
    fi

    if command -v supervisorctl >/dev/null 2>&1 \
        && supervisorctl status comfyui >/dev/null 2>&1; then
        supervisorctl restart comfyui
        log "  supervisorctl restart comfyui"
        return 0
    fi

    pid="$(comfy_main_pids | head -n 1)"
    if [[ -z "$pid" ]] && ! comfy_http_up; then
        log "  not running yet — the template will start ComfyUI after init"
        return 0
    fi

    if [[ -n "$pid" && -r "/proc/${pid}/cmdline" ]]; then
        cmdline="$(tr '\0' ' ' < "/proc/${pid}/cmdline")"
        cmdline="${cmdline%" "}"
    fi

    log "  stopping existing ComfyUI"
    if [[ -n "$pid" ]]; then
        pkill -TERM -f "${COMFYUI_PATH}/main.py" || true
        sleep 2
        pkill -KILL -f "${COMFYUI_PATH}/main.py" 2>/dev/null || true
    fi

    if [[ -n "${cmdline:-}" ]]; then
        # shellcheck disable=SC2086
        nohup bash -lc "$cmdline" >/tmp/comfyui-restart.log 2>&1 &
        log "  relaunched with previous args"
        return 0
    fi

    py="$(find_comfy_python)" || die "no python to relaunch ComfyUI"
    nohup "$py" "${COMFYUI_PATH}/main.py" --listen 0.0.0.0 --port 8188 --enable-cors-header \
        >/tmp/comfyui-restart.log 2>&1 &
    log "  launched ${COMFYUI_PATH}/main.py --listen 0.0.0.0 --port 8188"
}

is_selected() {
    local id="$1" item
    if [[ "$DO_ALL" -eq 1 ]]; then
        return 0
    fi
    for item in "${SELECTED[@]+"${SELECTED[@]}"}"; do
        if [[ "$item" == "$id" ]]; then
            return 0
        fi
    done
    return 1
}

copy_workflows() {
    local dest pack stems stem src
    dest="$(workflows_dest)"
    log "Copying workflows → ${dest}"
    for pack in "${SELECTED[@]}"; do
        stems="${PACK_WORKFLOWS[$pack]:-}"
        if [[ -z "$stems" ]]; then
            log "  ${pack}: no workflow JSON yet"
            continue
        fi
        IFS=',' read -r -a stem_arr <<< "$stems"
        for stem in "${stem_arr[@]}"; do
            stem="$(trim "$stem")"
            [[ -z "$stem" ]] && continue
            src="${WORKFLOWS_DIR}/${stem}.json"
            if [[ ! -f "$src" ]]; then
                warn "no workflow JSON for ${stem} (${src})"
                continue
            fi
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log "  would copy ${stem}.json"
                continue
            fi
            cp -f "$src" "${dest}/${stem}.json"
            log "  copied ${stem}.json"
        done
    done
}

download_file() {
    local url="$1" dest="$2"
    local tmp
    local -a curl_args
    tmp="${dest}.part"

    curl_args=(-fL --retry 3 --retry-delay 2 --continue-at - -o "$tmp")

    mkdir -p "$(dirname "$dest")"
    curl "${curl_args[@]}" "$url"
    mv -f "$tmp" "$dest"
}

download_models() {
    local pack dest_dir filename url dest key
    declare -A seen=()
    local missing=0

    [[ -f "$MANIFEST" ]] || die "missing ${MANIFEST}"

    log "Downloading models → ${COMFYUI_PATH}/models"
    while IFS='|' read -r pack dest_dir filename url || [[ -n "${pack:-}" ]]; do
        pack="$(trim "${pack:-}")"
        [[ -z "$pack" || "$pack" == \#* ]] && continue
        is_selected "$pack" || continue

        dest_dir="$(trim "${dest_dir:-}")"
        filename="$(trim "${filename:-}")"
        url="$(trim "${url:-}")"

        [[ -z "$dest_dir" || -z "$filename" ]] && continue

        key="${dest_dir}/${filename}"
        if [[ -n "${seen[$key]+x}" ]]; then
            continue
        fi
        seen[$key]=1

        dest="${COMFYUI_PATH}/models/${dest_dir}/${filename}"

        if [[ -f "$dest" && -s "$dest" ]]; then
            log "  skip (exists) ${key}"
            continue
        fi

        if [[ -z "$url" || "$url" == "-" ]]; then
            warn "no URL for ${key} (${pack}) — add it to models.txt"
            missing=$((missing + 1))
            continue
        fi

        if [[ "$DRY_RUN" -eq 1 ]]; then
            log "  would curl ${key}"
            log "           ${url}"
            continue
        fi

        log "  curl ${key}"
        download_file "$url" "$dest"
    done < "$MANIFEST"

    if [[ "$missing" -gt 0 && "$DRY_RUN" -eq 0 ]]; then
        warn "${missing} file(s) have no URL yet; fill models.txt and re-run"
    fi
}

add_selection() {
    local raw="$1" pack
    raw="$(trim "$raw")"
    [[ -z "$raw" ]] && return 0
    if pack="$(resolve_pack "$raw")"; then
        SELECTED+=("$pack")
        return 0
    fi
    die "unknown pack: ${raw} (try: bash init.sh --list)"
}

load_packs

while [[ $# -gt 0 ]]; do
    case "$1" in
        --workflow|-w)
            [[ $# -ge 2 ]] || die "$1 needs a pack name"
            add_selection "$2"
            shift 2
            ;;
        --all)
            DO_ALL=1
            shift
            ;;
        --list)
            LIST_ONLY=1
            shift
            ;;
        --comfyui)
            [[ $# -ge 2 ]] || die "--comfyui needs a path"
            COMFYUI_PATH="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --*)
            die "unknown flag: $1"
            ;;
        *)
            add_selection "$1"
            shift
            ;;
    esac
done

if [[ -n "${WORKFLOWS:-}" ]]; then
    IFS=',' read -r -a from_env <<< "$WORKFLOWS"
    for id in "${from_env[@]}"; do
        add_selection "$id"
    done
fi

if [[ "$LIST_ONLY" -eq 1 ]]; then
    list_packs
    exit 0
fi

if [[ "$DO_ALL" -eq 1 ]]; then
    SELECTED=("${PACK_IDS[@]}")
fi

if [[ ${#SELECTED[@]} -eq 0 ]]; then
    usage
    echo
    die "pass a pack (krea, zimage, flux, ltx), WORKFLOWS=krea,flux, or --all"
fi

declare -A uniq=()
unique_selected=()
for id in "${SELECTED[@]}"; do
    if [[ -z "${uniq[$id]+x}" ]]; then
        uniq[$id]=1
        unique_selected+=("$id")
    fi
done
SELECTED=("${unique_selected[@]}")

log "Packs: ${SELECTED[*]}"
if [[ "$DRY_RUN" -eq 1 && -z "$COMFYUI_PATH" ]]; then
    COMFYUI_PATH="${COMFYUI_PATH:-/workspace/ComfyUI}"
    log "ComfyUI: ${COMFYUI_PATH} (assumed; dry-run)"
else
    resolve_comfyui
    log "ComfyUI: ${COMFYUI_PATH}"
fi

install_comfy_gguf
enable_dev_mode
copy_workflows
download_models
restart_comfyui

log "Done."
