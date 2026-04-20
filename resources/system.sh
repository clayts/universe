set -ueo pipefail

case "${1:-}" in
  test)
    if [ "$#" -ge 3 ]; then
        echo "Test $2 at $3"
        nh os switch /etc/nixos -- --quiet --override-input "$2" "path:$3"
    else
        echo "Test"
        nh os switch /etc/nixos -- --quiet
    fi
    ;;
  sync)
    echo "Sync"
   	sudo nix flake update --flake /etc/nixos
    nh os switch /etc/nixos -- --quiet
    ;;
  clean)
    echo "Clean"
 	nh clean all --optimise
    ;;
  *)
  	echo "Usage: system <sync [path] | clean>"
  	exit 1
    ;;
esac
