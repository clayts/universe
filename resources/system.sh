set -ueo pipefail

case "${1:-}" in
  test)
	path=$2
	nh os switch /etc/nixos -- --override-input "universe" "path:$path"
    ;;
  update)
  	sudo nix flake update --flake /etc/nixos
    nh os switch /etc/nixos
    ;;
  clean)
 	nh clean all -k 3 && nix-store --optimise
    ;;
  *)
  	exit 1
    ;;
esac
