{pkgs, ...}: {
  home.packages = with pkgs; [
    (writers.writePython3Bin "persist-nix" {} (builtins.readFile ./persist-nix.py))
  ];
}
