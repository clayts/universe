{
  inputs = {
    nixpkgs = {};
    home-manager = {};
  };
  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {inherit system;};
    systemRelease = inputs.nixpkgs.lib.trivial.release;
    homeRelease = (builtins.fromJSON (builtins.readFile "${inputs.home-manager}/release.json")).release;
  in rec {
    templates = "${./templates}";
    safe = pkgs.writeShellApplication {
      name = "safe";
      runtimeInputs = with pkgs; [cryfs];
      text = builtins.readFile ./safe.sh;
    };
    style =
      import ./style.nix {inherit pkgs;};
    earthpaper = pkgs.writeShellApplication {
      name = "earthpaper";
      runtimeInputs = with pkgs; [jq curl dconf];
      text = builtins.readFile ./earthpaper.sh;
    };
    scan = pkgs.writeShellApplication {
      name = "scan";
      runtimeInputs = with pkgs; [nixos-facter jq alejandra];
      text = builtins.readFile ./scan.sh;
    };
    install-system = pkgs.writeShellApplication {
      name = "install-system";
      runtimeEnv = {inherit systemRelease homeRelease;};
      runtimeInputs = [scan];
      text = builtins.readFile ./install-system.sh;
    };
    install-home = pkgs.writeShellApplication {
      name = "install-home";
      runtimeEnv = {inherit homeRelease;};
      runtimeInputs = [];
      text = builtins.readFile ./install-home.sh;
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
