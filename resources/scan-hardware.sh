set -euo pipefail
report=$(sudo nixos-facter | jq '.hardware.disk |= map(select(.class_list | contains(["usb"]) | not))')
disk=$(echo "$report" | jq -r '
	[ .hardware.disk[].unix_device_names
	    | map(select(contains("/dev/disk/by-id/")))
	    | max_by(length) // empty ]
	| if length == 1 then .[0] else "" end
')
swap=$(free -m | awk '/^Mem:/{print $2 * 2}')M
alejandra -q <<-EOF
	{...}: {
	  fileSystems."/system/data".neededForBoot = true;
	  disko.devices.disk.main = {
	    device = "$disk";
	    type = "disk";
	    content = {
	      type = "gpt";
	      partitions = {
	        boot = {
	          type = "EF00";
	          size = "2G";
	          content = {
	            type = "filesystem";
	            format = "vfat";
	            mountpoint = "/system/boot";
	            mountOptions = ["umask=0077"];
	          };
	        };
	        state = {
	          size = "6G";
	          content = {
	            type = "btrfs";
	            extraArgs = ["-f"];
	            mountpoint = "/system/state";
	            mountOptions = [
	              "compress=zstd"
	              "noatime"
	            ];
	            subvolumes."@present" = {
	              mountpoint = "/";
	              mountOptions = [
	                "compress=zstd"
	                "noatime"
	              ];
	            };
	          };
	        };
	        data = {
	          size = "100%";
	          content = {
	            type = "filesystem";
	            format = "xfs";
	            mountpoint = "/system/data";
	          };
	        };
	        swap = {
	          size = "$swap";
	          content = {
	            type = "swap";
	            discardPolicy = "both";
	            resumeDevice = true;
	          };
	        };
	      };
	    };
	  };
	  hardware.facter.reportPath = builtins.toFile "hardware.json" ''
	$report
	  '';
	}
EOF
