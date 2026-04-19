set -ueo pipefail

case "${1:-}" in
  sync-next-boot)
    if [ "$#" -ge 2 ]; then
        echo "Universe sync next boot with path override: $2"
        nh os boot /etc/nixos -- --quiet --override-input "universe" "path:$2"
    else
        echo "Universe sync next boot"
        sudo nix flake update --flake /etc/nixos
        nh os boot /etc/nixos -- --quiet
    fi
    ;;
  sync)
    if [ "$#" -ge 2 ]; then
        echo "Universe sync with path override: $2"
        nh os switch /etc/nixos -- --quiet --override-input "universe" "path:$2"
    else
        echo "Universe sync"
       	sudo nix flake update --flake /etc/nixos
        nh os switch /etc/nixos -- --quiet
    fi
    ;;
  clean)
    echo "Clean"
 	nh clean all --optimise
    ;;
  *)
  	echo "Usage: system [sync|clean]"
  	exit 1
    ;;
esac
