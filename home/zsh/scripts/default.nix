{pkgs, ...}: {
  home.packages = with pkgs; [
    (writers.writePython3Bin "persist-nix" {} (builtins.readFile ./persist-nix.py))
    (pkgs.writeShellScriptBin "clean" ''nh clean all -k 3 && nix-store --optimise'')
    (pkgs.writeShellScriptBin "switch" ''nh os switch /etc/nixos'')
    (pkgs.writeShellScriptBin "update" ''cd /etc/nixos && sudo nix flake update'')
  ];
}
