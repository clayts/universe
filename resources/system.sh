set -ueo pipefail

case "${1:-}" in
  test)
	path=$2
	nh os switch -- --quiet --override-input "universe" "path:$path"
    ;;
  update)
  	sudo nix flake update --flake /etc/nixos
    nh os switch -- --quiet
    ;;
  clean)
 	nh clean all --optimise # -K 7d
	echo "Cleaning /system/state/past"
	sudo rm -rf /system/state/past/*
    ;;
  *)
  	echo "Usage: system [clean/update/test]"
  	exit 1
    ;;
esac
