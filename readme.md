# Universe

## To Do
- hardware stuff
	- swap play key binding to win+z
- theme colours
- include persist as proper script in nix

## Installation

Generate /etc/nixos/hardware.nix:
```bash
nix run github:clayts/universe#scan > /etc/nixos/hardware.nix
```

Create /etc/nixos/flake.nix:
```nix
{
  inputs.universe.url = "github:clayts/universe";
  outputs = inputs: inputs.universe.system "aura" [./hardware.nix];
}
```

Finalise:
- make password hashes in /data/etc/password-files/{user,guest,root}
