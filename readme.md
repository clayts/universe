# Universe

## To Do
- hardware stuff
	- swap play key binding to win+z
- theme colours
- include persist as proper script in nix

## Installation

Become root
```bash
sudo su
```

Generate hardware.nix:
```bash
nix run --experimental-features "nix-command flakes" \
	github:clayts/universe#scan > hardware.nix
```

Run disko
```bash
nix run --experimental-features "nix-command flakes" \
	github:nix-community/disko/latest -- \
	--mode destroy,format,mount hardware.nix
```

Make passwords
```bash
mkdir -p /mnt/data/etc/nixos/passwords
mkpasswd > /mnt/data/etc/nixos/passwords/root
mkpasswd > /mnt/data/etc/nixos/passwords/user
mkpasswd > /mnt/data/etc/nixos/passwords/guest
```


Create /mnt/data/etc/nixos/flake.nix:
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
nixos-install --flake /mnt/data/etc/nixos
```
