set -ueo pipefail

case "${1:-}" in
  test)
	path=$2
	nh os switch -- --override-input "universe" "path:$path"
    ;;
  update)
  	sudo nix flake update --flake /etc/nixos
    nh os switch
    ;;
  clean)
 	nh clean all --optimise -K 7d
	delete_subvolume_recursively() {
	    IFS=$'\n'
	    for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
	        delete_subvolume_recursively "/system/state/$i"
	    done
	    btrfs subvolume delete "$1"
	}
	for i in $(find /system/state/ -maxdepth 1 -mtime +7); do
	    delete_subvolume_recursively "$i"
	done
    ;;
  *)
  	echo "Usage: system [clean/update/test]"
  	exit 1
    ;;
esac
