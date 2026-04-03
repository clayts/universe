# Universe

## To Do
- hardware stuff
	- swap play key binding to win+z
- theme colours
- include persist as proper script in nix

## Installation

Generate /etc/nixos/hardware.nix:
```bash
sudo nix run --experimental-features "nix-command flakes" github:clayts/universe#scan > /etc/nixos/hardware.nix
```

run disko

Create /etc/nixos/flake.nix:
```nix
{
  inputs.universe.url = "github:clayts/universe";
  outputs = inputs: inputs.universe.system "aura" [./hardware.nix];
}
```

mkdir /mnt/nix
mkdir /mnt/data/nix
mount --bind /mnt/data/nix /mnt/nix

Finalise:
- make password hashes in /data/etc/password-files/{user,guest,root}
