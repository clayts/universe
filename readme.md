# Universe

## To Do
- hardware stuff
	- swap play key binding to win+z
- theme colours
- include persist as proper script in nix

## Installation

Become root

Generate hardware.nix:
```bash
nix run --experimental-features "nix-command flakes" \
	github:clayts/universe#scan > /etc/nixos/hardware.nix
```

Run disko
```bash
nix run --experimental-features "nix-command flakes" \
	github:nix-community/disko/latest -- \
	--mode destroy,format,mount hardware.nix
```

Make passwords
```bash
mkdir -p /mnt/etc/nixos/passwords
mkpasswd > /mnt/etc/nixos/passwords/root
mkpasswd > /mnt/etc/nixos/passwords/user
mkpasswd > /mnt/etc/nixos/passwords/guest
```


Create /etc/nixos/flake.nix:
```nix
{
  inputs.universe.url = "github:clayts/universe";
  outputs = inputs: inputs.universe.system "aura" [./hardware.nix];
}
```

Bind /nix
```bash
mkdir /mnt/nix
mkdir /mnt/data/nix
mount --bind /mnt/data/nix /mnt/nix
```

Install
```bash
nixos-install --flake /mnt/etc/nixos
```
