{
  inputs.nixpkgs = {};
  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {inherit system;};
  in rec {
    style =
      import ./style.nix {inherit pkgs;};
    earthpaper = pkgs.writeShellApplication {
      name = "earthpaper";
      runtimeInputs = with pkgs; [jq curl dconf];
      text = builtins.readFile ./earthpaper.sh;
    };
    scan-hardware = pkgs.writeShellApplication {
      name = "scan";
      runtimeInputs = with pkgs; [nixos-facter jq alejandra];
      text = builtins.readFile ./scan-hardware.sh;
    };
    install-system = pkgs.writeShellApplication {
      name = "install";
      runtimeEnv.release = inputs.nixpkgs.lib.trivial.release;
      runtimeInputs = [scan-hardware];
      text = builtins.readFile ./install-system.sh;
    };
    system = pkgs.writeShellApplication {
      name = "system";
      text = builtins.readFile ./system.sh;
    };
    persist =
      pkgs.writers.writePython3Bin "persist" {} (builtins.readFile ./persist.py);
    rizzlefetch = pkgs.writeShellApplication {
      name = "rizzlefetch";
      runtimeInputs = with pkgs; [
        toilet
        (python313.withPackages (ps: with ps; [terminaltexteffects]))
      ];
      text = ''
        python ${./rizzlefetch.py}
      '';
    };
  };
}
