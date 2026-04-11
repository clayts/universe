set -uxeo pipefail
hostName=$1
sudo scan-hardware > /tmp/hardware.nix
sudo nix run --experimental-features "nix-command flakes" github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/hardware.nix
sudo mkdir -p /mnt/data/etc/nixos/passwords
echo "Enter password for root:"
mkpasswd | sudo tee /mnt/data/etc/nixos/passwords/root > /dev/null
echo "Enter password for user:"
mkpasswd | sudo tee /mnt/data/etc/nixos/passwords/user > /dev/null
echo "Enter password for guest:"
mkpasswd | sudo tee /mnt/data/etc/nixos/passwords/guest > /dev/null
echo "{
  inputs.universe.url = \"github:clayts/universe\";
  outputs = inputs: {
    nixosConfigurations = {
      \"$hostName\" = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          # Universe
          {
            networking.hostName = \"$hostName\";
            system.stateVersion = \"$release\";
            imports = [inputs.universe.nixosModules.default ./hardware.nix];
          }

          # System
          {}
        ];
      };
    };
  };
}" | sudo tee /mnt/data/etc/nixos/flake.nix > /dev/null
sudo mv /tmp/hardware.nix /mnt/data/etc/nixos/
sudo mkdir /mnt/nix
sudo mkdir /mnt/data/nix
sudo mount --bind /mnt/data/nix /mnt/nix
sudo nixos-install --flake /mnt/data/etc/nixos#"$hostName"
