#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage:
  system --sync [--boot] [--from <input>:<path>] [--update]
  system --clean

Options:
  --sync                    Rebuild the system (via nh os)
  --clean                   Run garbage collection / store optimisation
  --boot                    (sync only) Apply on next boot instead of switching now
  --from <input>:<path>     (sync only) Override a flake input with a local path,
                            e.g. --from nixpkgs:/home/me/nixpkgs
  --update                  (requires --from) Verify the --from repo is clean,
                            update its flake.lock, commit and push it, then
                            run an official sync of the main flake (no
                            override) to pick up the new commit
EOF
}

MODE=""
BOOT=0
FROM=""
UPDATE=0

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
        --from)
            if [[ -z "${2:-}" || "$2" == --* ]]; then
                echo "Error: --from requires a value in the form <input>:<path>" >&2
                exit 1
            fi
            FROM="$2"
            shift 2
            ;;
        --update)
            UPDATE=1
            shift
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
    if [[ $BOOT -eq 1 || -n "$FROM" || $UPDATE -eq 1 ]]; then
        echo "Error: --boot, --from, and --update are only valid with --sync" >&2
        exit 1
    fi
fi

if [[ $UPDATE -eq 1 && -z "$FROM" ]]; then
    echo "Error: --update requires --from" >&2
    exit 1
fi

FLAKE_DIR="/etc/nixos"

if [[ -n "$FROM" ]]; then
    if [[ "$FROM" != *:* ]]; then
        echo "Error: --from must be in the form <input>:<path>" >&2
        exit 1
    fi
    FROM_INPUT="${FROM%%:*}"
    FROM_PATH="${FROM#*:}"
fi

# --- actions --------------------------------------------------------

# Checks that $1 (a local flake repo) is clean, updates its flake.lock,
# commits, and pushes it. Aborts if the repo has uncommitted changes.
push_flake_update() {
    local repo="$1"

    if [[ -n "$(git -C "$repo" status --porcelain)" ]]; then
        echo "Error: $repo has uncommitted changes; commit or stash them before using --update" >&2
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

    if [[ -n "$FROM" ]]; then
        if [[ $UPDATE -eq 1 ]]; then
            push_flake_update "$FROM_PATH"
            echo "Running official sync of $FLAKE_DIR..."
            sudo nix flake update --flake "$FLAKE_DIR"
            nh os "$subcmd" "$FLAKE_DIR" -- --quiet
            return
        fi

        echo "Overriding $FROM_INPUT with path:$FROM_PATH"
        nh os "$subcmd" "$FLAKE_DIR" -- --quiet --override-input "$FROM_INPUT" "path:$FROM_PATH"
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
