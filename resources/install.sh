set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi

scan > /tmp/hardware.nix
nix run --experimental-features "nix-command flakes" github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/hardware.nix
mkdir -p /mnt/data/etc/nixos/passwords
echo root
mkpasswd > /mnt/data/etc/nixos/passwords/root
echo user
mkpasswd > /mnt/data/etc/nixos/passwords/user
echo guest
mkpasswd > /mnt/data/etc/nixos/passwords/guest
echo "{
    inputs.universe.url = \"github:clayts/universe\";
    outputs = inputs: inputs.universe.system \"$1\" [./hardware.nix];
}" | alejandra -q > /mnt/data/etc/nixos/flake.nix
mv /tmp/hardware.nix /mnt/data/etc/nixos/
mkdir /mnt/nix
mkdir /mnt/data/nix
mount --bind /mnt/data/nix /mnt/nix
nixos-install --flake /mnt/data/etc/nixos#"$1"
