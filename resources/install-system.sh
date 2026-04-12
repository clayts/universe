set -uxeo pipefail
hostName=$1
hardware=$(mktemp)
scan-hardware > "$hardware"
sudo nix run --experimental-features "nix-command flakes" github:nix-community/disko/latest -- --mode destroy,format,mount "$hardware"
sudo mkdir -p /mnt/system/data/etc/nixos/passwords
echo "Enter password for root:"
mkpasswd | sudo tee /mnt/system/data/etc/nixos/passwords/root > /dev/null
echo "Enter password for user:"
mkpasswd | sudo tee /mnt/system/data/etc/nixos/passwords/user > /dev/null
echo "Enter password for guest:"
mkpasswd | sudo tee /mnt/system/data/etc/nixos/passwords/guest > /dev/null
sudo tee /mnt/system/data/etc/nixos/flake.nix > /dev/null <<-EOF
	{
	  inputs.universe.url = "github:clayts/universe";
	  outputs = inputs: {
	    nixosConfigurations = {
	      system = inputs.nixpkgs.lib.nixosSystem {
	        specialArgs = {inherit inputs;};
	        modules = [
	          # System
	          {
	            networking.hostName = "$hostName";
	            system.stateVersion = "$systemRelease";
	            home-manager.sharedModules = [{ home.stateVersion = "$homeRelease"; }];
	          }

	          # Modules
	          inputs.universe.nixosModules.default
	          ./hardware.nix
	        ];
	      };
	    };
	  };
	}
EOF
cat "$hardware" | sudo tee /mnt/system/data/etc/nixos/hardware.nix > /dev/null
sudo mkdir /mnt/nix
sudo mkdir /mnt/system/data/nix
sudo mount --bind /mnt/system/data/nix /mnt/nix
sudo nixos-install --flake /mnt/system/data/etc/nixos#system
