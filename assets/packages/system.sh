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
                           clean and in sync with its upstream, update its
                           flake.lock, commit and push it, then run a plain
                           official sync of the main flake.
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

# Checks that $1 (a local flake repo) is clean and in sync with its upstream,
# updates its flake.lock, commits, and pushes it. Aborts on uncommitted
# changes or on commits that exist locally but not on the remote, so the
# main flake is never locked against a stale remote.
push_flake_update() {
    local repo="$1"

    if [[ -n "$(git -C "$repo" status --porcelain)" ]]; then
        echo "Error: $repo has uncommitted changes; commit or stash them before using --update-input" >&2
        exit 1
    fi

    local upstream
    upstream="$(git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name '@{u}')" || {
        echo "Error: no upstream configured for the current branch in $repo" >&2
        exit 1
    }

    git -C "$repo" fetch

    if [[ -n "$(git -C "$repo" log --oneline "$upstream"..HEAD)" ]]; then
        echo "Error: $repo has unpushed commits; push or reset them before using --update-input" >&2
        git -C "$repo" log --oneline "$upstream"..HEAD >&2
        exit 1
    fi

    # Drop this block if you'd rather let the push fail on non-fast-forward.
    if [[ -n "$(git -C "$repo" log --oneline HEAD.."$upstream")" ]]; then
        echo "Error: $repo is behind $upstream; pull before using --update-input" >&2
        git -C "$repo" log --oneline HEAD.."$upstream" >&2
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
    git -C "$repo" push origin HEAD
}

do_sync() {
    local subcmd="switch"
    if [[ $BOOT -eq 1 ]]; then
        subcmd="boot"
    fi

    if [[ -n "$INPUT_NAME" ]]; then
        echo "Overriding $INPUT_NAME with path:$INPUT_PATH"
        nh os "$subcmd" "$FLAKE_DIR" -- --quiet --override-input "$INPUT_NAME" "path:$INPUT_PATH"
    elif [[ -n "$UPDATE_INPUT_PATH" ]]; then
        push_flake_update "$UPDATE_INPUT_PATH"
        echo "Running official sync of $FLAKE_DIR..."
        # --refresh: without it, nix may reuse a cached resolution (tarball-ttl,
        # root's cache under sudo) and lock to the pre-push revision.
        sudo nix flake update --refresh --flake "$FLAKE_DIR"
        nh os "$subcmd" "$FLAKE_DIR" -- --quiet
    else
        sudo nix flake update --refresh --flake "$FLAKE_DIR"
        nh os "$subcmd" "$FLAKE_DIR" -- --quiet
    fi
}

do_clean() {
    nh clean all --optimise
    nh os boot
}

case "$MODE" in
    sync)  do_sync ;;
    clean) do_clean ;;
esac
