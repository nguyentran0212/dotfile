#!/usr/bin/env bash
# -------------------------------------------------------------
# devc – portable wrapper for the VS Code Dev‑Container CLI
#
# Updated to work with the current label names:
#   - devcontainer.local_folder  (the workspace folder)
#   - devcontainer.config_file  (absolute path to .devcontainer/devcontainer.json)
#
# All other behaviour is unchanged.
# -------------------------------------------------------------
set -euo pipefail

######################################
## 0. Helper / sanity checks
######################################

# Is devcontainer CLI available?
if ! command -v devcontainer >/dev/null 2>&1; then
    echo "❌  devcontainer CLI not found – install it with:" >&2
    echo "     npm i -g @vscode/devcontainers-cli" >&2
    exit 1
fi

# Docker / Podman ?
if ! command -v docker >/dev/null 2>&1 && ! command -v podman >/dev/null 2>&1; then
    echo "❌  Neither docker nor podman is installed." >&2
    exit 1
fi
DOCKER_CMD=${DOCKER_CMD:-$(command -v docker || command -v podman)}

# Current folder – used as <workspace-folder>
WORKDIR=$(pwd)
DEVCONTAINER_WORKSPACE_ARG="--workspace-folder ${WORKDIR}"

######################################
## 1. Small helpers for the container
######################################

sanitize() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9._-]/_/g'
}

# Detect the running dev‑container (first label, then config_file, finally name)
find_container_id() {
    # ① label that points directly to the workspace folder
    local id=$($DOCKER_CMD ps -q --filter "label=devcontainer.local_folder=${WORKDIR}" | head -n1)

    if [[ -z $id ]]; then
        # ② fallback: config_file (full path to devcontainer.json)
        local cfg_path=$(realpath "${WORKDIR}/.devcontainer/devcontainer.json" 2>/dev/null || echo "")
        if [[ -n $cfg_path ]]; then
            id=$($DOCKER_CMD ps -q --filter "label=devcontainer.config_file=${cfg_path}" | head -n1)
        fi
    fi

    if [[ -z $id ]]; then
        # ③ final fallback: container name that contains the sanitized folder basename
        local base=$(basename "$WORKDIR")
        local sbase=$(sanitize "$base")
        id=$($DOCKER_CMD ps -q --filter "name=${sbase}" | head -n1)
    fi

    echo "${id:-}"
}

# Get the image a container was built from
container_image() {
    local cid="$1"
    [[ -z $cid ]] && return
    $DOCKER_CMD inspect --format='{{.Image}}' "$cid" 2>/dev/null || true
}

######################################
## 2. Main command dispatcher
######################################

cmd=${1:-}
case "$cmd" in

    # ---  Up --------------------------------------------------
    up|start)
        echo "🚀  Starting the dev container (may pull a new image)…"
        devcontainer up $DEVCONTAINER_WORKSPACE_ARG
        ;;

    # ---  Interactive shell ------------------------------------
    shell|exec|nvim)
        echo "🖥️  Opening an interactive zsh inside the container… (Ctrl‑D to exit)"
        devcontainer exec $DEVCONTAINER_WORKSPACE_ARG  /bin/zsh
        ;;

    # ---  tmux inside container ---------------------------------
    tmux)
        SESSION=${2:-devc}
        echo "📦  Launching tmux session '$SESSION' INSIDE the dev‑container…"
        devcontainer exec $DEVCONTAINER_WORKSPACE_ARG  \
            tmux new-session -A -s "$SESSION" \; display-message "tmux started in container"
        ;;

    # ---  host‑side tmux window ---------------------------------
    host-tmux)
        if ! command -v tmux >/dev/null 2>&1; then
            echo "❌  Host tmux not found – install it first." >&2
            exit 1
        fi

        WIN=${2:-devc}
        echo "🖥️  Creating host‑side tmux window '$WIN' that execs into the container…"
        tmux new-window -n "$WIN" \
            "devcontainer exec $DEVCONTAINER_WORKSPACE_ARG  /bin/zsh"
        ;;

    # ---  Stop / remove container --------------------------------
    stop)
        cid=$(find_container_id)
        if [[ -z $cid ]]; then
            echo "⚠️  No running dev-container found for $(basename "$WORKDIR")." >&2
        else
            # Try to find a docker-compose project label
            compose_project=$($DOCKER_CMD inspect --format '{{ index .Config.Labels "com.docker.compose.project" }}' "$cid" 2>/dev/null)

            if [[ -n "$compose_project" ]]; then
                echo "Compose project '$compose_project' found."
                echo "Gracefully stopping all services for this project with 'docker compose stop'…"
                # Use the project name directly with 'docker compose stop'
                # This correctly stops all containers for the project without removing them.
                $DOCKER_CMD compose -p "$compose_project" stop
            else
                echo "This does not appear to be a docker-compose project."
                echo "🛑  Stopping single container $cid …"
                $DOCKER_CMD stop "$cid" || true
            fi
        fi
        ;;

    # ---  Down / remove container --------------------------------
    down)
        cid=$(find_container_id)
        if [[ -z $cid ]]; then
            echo "⚠️  No running dev-container found for $(basename "$WORKDIR")." >&2
        else
            # Try to find a docker-compose project label
            compose_project=$($DOCKER_CMD inspect --format '{{ index .Config.Labels "com.docker.compose.project" }}' "$cid" 2>/dev/null)

            if [[ -n "$compose_project" ]]; then
                echo "Compose project '$compose_project' found."
                echo "Gracefully stopping all services for this project with 'docker compose down'…"
                # Use the project name directly with 'docker compose down'
                # This correctly shuts down all containers and networks for the project.
                $DOCKER_CMD compose -p "$compose_project" down
            else
                echo "This does not appear to be a docker-compose project."
                echo "🛑  Stopping and removing single container $cid …"
                $DOCKER_CMD rm -f "$cid" || true
            fi
        fi
        ;;

    # ---  Delete (container + image) ----------------------------
    delete)
        cid=$(find_container_id)
        if [[ -z $cid ]]; then
            echo "⚠️  No running dev‑container found for $(basename "$WORKDIR")." >&2
        else
            img=$(container_image "$cid")
            echo "🗑️  Removing container $cid …"
            $DOCKER_CMD rm -f "$cid" || true

            if [[ -n $img ]]; then
                echo "📦  Removing image $img …"
                $DOCKER_CMD rmi -f "$img" || true   # force‑remove
            fi
        fi
        ;;

    # ---  Clean – stop + prune dangling resources -----------------
    clean)
        cid=$(find_container_id)
        if [[ -n $cid ]]; then
            echo "🛑  Stopping and removing container $cid …"
            $DOCKER_CMD rm -f "$cid" || true
        fi

        # The image label that dev‑containers used to set has changed.
        # Prune *any* images whose labels contain the word “devcontainer”.
        echo "🚮  Pruning dangling images and volumes created by dev‑containers…"
        $DOCKER_CMD rmi -f $( \
            docker images --quiet --filter "label=devcontainer.local_folder" 2>/dev/null || true ) 2>/dev/null || true
        $DOCKER_CMD volume prune -f 2>/dev/null || true
        ;;

    # ---  Help / unknown -----------------------------------------
    *)
        echo "❓  Unknown command: ${cmd:-<none>}" >&2
        echo
        echo "Usage:" >&2
        echo "   $(basename "$0") up                # start / pull the container" >&2
        echo "   $(basename "$0") shell             # open an interactive zsh (good for nvim)" >&2
        echo "   $(basename "$0") tmux [name]       # run a tmux session inside the container" >&2
        echo "   $(basename "$0") host-tmux [win]   # create a host‑side tmux window that execs into it" >&2
        echo
        echo "   $(basename "$0") stop              # stop and remove running dev‑container" >&2
        echo "   $(basename "$0") delete            # stop & delete the container & its image" >&2
        echo "   $(basename "$0") clean             # stop + prune dangling images/volumes" >&2
        exit 1
        ;;
esac

exit 0
