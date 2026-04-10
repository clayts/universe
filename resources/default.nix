{pkgs, ...}: rec {
  style = import ./style.nix {inherit pkgs;};
  earthpaper = pkgs.writeShellApplication {
    name = "earthpaper";
    runtimeInputs = with pkgs; [jq curl dconf];
    text = builtins.readFile ./earthpaper.sh;
  };
  scan = pkgs.writeShellApplication {
    name = "scan";
    runtimeInputs = with pkgs; [nixos-facter jq alejandra];
    text = builtins.readFile ./resources/scan.sh;
  };
  install = pkgs.writeShellApplication {
    name = "install";
    runtimeInputs = [scan pkgs.alejandra];
    text = builtins.readFile ./resources/install.sh;
  };
  persist = pkgs.writers.writePython3Bin "persist" {} (builtins.readFile ./persist.py);
  rizzlefetch = pkgs.writeScriptBin "rizzlefetch" ''
    export PATH=${pkgs.lib.makeBinPath [pkgs.toilet]}:$PATH
    ${pkgs.python313.withPackages (ps: with ps; [terminaltexteffects])}/bin/python ${./rizzlefetch.py}
  '';
}
