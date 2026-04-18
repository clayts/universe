set -ueo pipefail

case "${1:-}" in
  sync)
    if [ "$#" -ge 2 ]; then
        echo "Universe sync with path override: $2..."
        nh os switch /etc/nixos -- --quiet --override-input "universe" "path:$2"
    else
        echo "Universe sync..."
       	sudo nix flake update --flake /etc/nixos
        nh os switch /etc/nixos -- --quiet
    fi
    ;;
  clean)
 	nh clean all --optimise
	echo "Cleaning /system/state/past"
	sudo rm -rf /system/state/past/*
    ;;
  *)
  	echo "Usage: system [sync|clean]"
  	exit 1
    ;;
esac
