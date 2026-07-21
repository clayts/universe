set -ueo pipefail

case "${1:-}" in
  test)
    if [ "$#" -ge 3 ]; then
        echo "Overriding $2 with path:$3"
        nh os switch /etc/nixos -- --quiet --override-input "$2" "path:$3"
    else
        nh os switch /etc/nixos -- --quiet
    fi
    ;;
  test-boot)
    if [ "$#" -ge 3 ]; then
        echo "Overriding $2 with path:$3"
        nh os boot /etc/nixos -- --quiet --override-input "$2" "path:$3"
    else
        nh os boot /etc/nixos -- --quiet
    fi
    ;;
  sync)
   	sudo nix flake update --flake /etc/nixos
    nh os switch /etc/nixos -- --quiet
    ;;
  sync-boot)
   	sudo nix flake update --flake /etc/nixos
    nh os boot /etc/nixos -- --quiet
    ;;
  clean)
 	nh clean all --optimise
    ;;
  *)
  	echo "Usage: system <test INPUT DIR | sync | clean>"
  	exit 1
    ;;
esac
