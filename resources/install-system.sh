set -uxeo pipefail
name=$1
hardware=$(mktemp)
scan-hardware > "$hardware"
sudo nix run --experimental-features "nix-command flakes" github:nix-community/disko/latest -- --mode destroy,format,mount "$hardware"
sudo mkdir -p /mnt/system/data/etc/nixos/passwords
mkpasswd | sudo tee /mnt/system/data/etc/nixos/passwords/root > /dev/null
mkpasswd | sudo tee /mnt/system/data/etc/nixos/passwords/user > /dev/null
mkpasswd | sudo tee /mnt/system/data/etc/nixos/passwords/guest > /dev/null
sudo tee /mnt/system/data/etc/nixos/flake.nix > /dev/null <<-EOF
	{
	  inputs.universe.url = "github:clayts/universe";
	  outputs = inputs: inputs.universe.nixosSystem {
	    name = "$name";
	    foundation = {
	      system = "$systemRelease";
	      homes = "$homeRelease";
	    };
		hardware = ./hardware.nix;
	  };
	}
EOF
cat "$hardware" | sudo tee /mnt/system/data/etc/nixos/hardware.nix > /dev/null
sudo mkdir /mnt/nix
sudo mkdir /mnt/system/data/nix
sudo mount --bind /mnt/system/data/nix /mnt/nix
sudo nixos-install --flake /mnt/system/data/etc/nixos#system
