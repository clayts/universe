#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage:
  system --sync [--boot] [--input <input> <path> | --update-input <path>]
  system --clean

Options:
  --sync                   Rebuild the system (via nh os)
  --clean                  Run garbage collection / store optimisation
  --boot                   (sync only) Apply on next boot instead of switching now
  --input <input> <path>   (sync only) Override a flake input with a local path,
                           e.g. --input nixpkgs ~/nixpkgs
  --update-input <path>    (sync only) Verify the flake repo at <path> is
                           clean, update its flake.lock, commit and push it,
                           then run a plain official sync of the main flake.
                           Mutually exclusive with --input.
EOF
}

MODE=""
BOOT=0
INPUT_NAME=""
INPUT_PATH=""
UPDATE_INPUT_PATH=""

# --- parse args -------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --sync)
            MODE="sync"
            shift
            ;;
        --clean)
            MODE="clean"
            shift
            ;;
        --boot)
            BOOT=1
            shift
            ;;
        --input)
            if [[ -z "${2:-}" || "$2" == --* || -z "${3:-}" || "$3" == --* ]]; then
                echo "Error: --input requires two values: <input> <path>" >&2
                exit 1
            fi
            INPUT_NAME="$2"
            INPUT_PATH="$3"
            shift 3
            ;;
        --update-input)
            if [[ -z "${2:-}" || "$2" == --* ]]; then
                echo "Error: --update-input requires a path" >&2
                exit 1
            fi
            UPDATE_INPUT_PATH="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage
            exit 1
            ;;
    esac
done

# --- validate -----------------------------------------------------------
if [[ -z "$MODE" ]]; then
    echo "Error: must specify --sync or --clean" >&2
    usage
    exit 1
fi

if [[ "$MODE" == "clean" ]]; then
    if [[ $BOOT -eq 1 || -n "$INPUT_NAME" || -n "$UPDATE_INPUT_PATH" ]]; then
        echo "Error: --boot, --input, and --update-input are only valid with --sync" >&2
        exit 1
    fi
fi

if [[ -n "$INPUT_NAME" && -n "$UPDATE_INPUT_PATH" ]]; then
    echo "Error: --input and --update-input are mutually exclusive" >&2
    exit 1
fi

FLAKE_DIR="/etc/nixos"

# --- actions --------------------------------------------------------

# Checks that $1 (a local flake repo) is clean, updates its flake.lock,
# commits, and pushes it. Aborts if the repo has uncommitted changes.
push_flake_update() {
    local repo="$1"

    if [[ -n "$(git -C "$repo" status --porcelain)" ]]; then
        echo "Error: $repo has uncommitted changes; commit or stash them before using --update-input" >&2
        exit 1
    fi

    echo "Updating flake.lock in $repo..."
    nix flake update --flake "$repo"

    if [[ -z "$(git -C "$repo" status --porcelain)" ]]; then
        echo "flake.lock already up to date; nothing to push"
        return
    fi

    git -C "$repo" add flake.lock
    git -C "$repo" commit -m "Update flake.lock"
    git -C "$repo" push
}

do_sync() {
    local subcmd="switch"
    [[ $BOOT -eq 1 ]] && subcmd="boot"

    if [[ -n "$INPUT_NAME" ]]; then
        echo "Overriding $INPUT_NAME with path:$INPUT_PATH"
        nh os "$subcmd" "$FLAKE_DIR" -- --quiet --override-input "$INPUT_NAME" "path:$INPUT_PATH"
    elif [[ -n "$UPDATE_INPUT_PATH" ]]; then
        push_flake_update "$UPDATE_INPUT_PATH"
        echo "Running official sync of $FLAKE_DIR..."
        sudo nix flake update --flake "$FLAKE_DIR"
        nh os "$subcmd" "$FLAKE_DIR" -- --quiet
    else
        nh os "$subcmd" "$FLAKE_DIR" -- --quiet
    fi
}

do_clean() {
    nh clean all --optimise
}

case "$MODE" in
    sync)  do_sync ;;
    clean) do_clean ;;
esac
