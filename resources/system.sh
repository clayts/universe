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
 	nh clean all --optimise -K 7d

	echo "Cleaning /system/state"
	delete_subvolume_recursively() {
	    local IFS=$'\n'
	    for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
	        delete_subvolume_recursively "/system/state/$i"
	    done
	    btrfs subvolume delete "$1"
	}
	while IFS= read -r -d '' i; do
	    delete_subvolume_recursively "$i"
		echo "removed: $i"
	done < <(find /system/state/ -maxdepth 1 -mtime +7 -print0)
    ;;
  *)
  	echo "Usage: system [clean/update/test]"
  	exit 1
    ;;
esac
