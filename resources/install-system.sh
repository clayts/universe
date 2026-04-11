set -uxeo pipefail
hostName=$1
sudo scan-hardware > /tmp/hardware.nix
sudo nix run --experimental-features "nix-command flakes" github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/hardware.nix
sudo mkdir -p /mnt/system/data/etc/nixos/passwords
echo "Enter password for root:"
mkpasswd | sudo tee /mnt/system/data/etc/nixos/passwords/root > /dev/null
echo "Enter password for user:"
mkpasswd | sudo tee /mnt/system/data/etc/nixos/passwords/user > /dev/null
echo "Enter password for guest:"
mkpasswd | sudo tee /mnt/system/data/etc/nixos/passwords/guest > /dev/null
sudo tee /mnt/system/data/etc/nixos/flake.nix > /dev/null <<-EOF
	{
	  inputs.universe.url = \"github:clayts/universe\";
	  outputs = inputs: {
	    nixosConfigurations = {
	      system = inputs.nixpkgs.lib.nixosSystem {
	        specialArgs = {inherit inputs;};
	        modules = [
	          # System
	          {
	            networking.hostName = \"$hostName\";
	            system.stateVersion = \"$systemRelease\";
	            home-manager.sharedModules = [{ home.stateVersion = \"$homeRelease\"; }];
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
sudo mv /tmp/hardware.nix /mnt/system/data/etc/nixos/
sudo mkdir /mnt/nix
sudo mkdir /mnt/system/data/nix
sudo mount --bind /mnt/system/data/nix /mnt/nix
sudo nixos-install --flake /mnt/system/data/etc/nixos#system
