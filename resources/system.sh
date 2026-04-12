set -ueo pipefail

case "${1:-}" in
  test)
	path=$2
	nh os switch /etc/nixos#system -- --override-input "universe" "path:$path"
    ;;
  update)
  	sudo nix flake update --flake /etc/nixos
    nh os switch /etc/nixos#system
    ;;
  clean)
 	nh clean all -k 3 && nix-store --optimise
    ;;
  *)
  	echo "Usage: system [clean/update/test]"
  	exit 1
    ;;
esac
