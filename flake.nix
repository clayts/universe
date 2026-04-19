{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme/master";
      flake = false;
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        nixpkgs.follows = "";
        home-manager.follows = "";
      };
    };
    resources = {
      url = ./resources;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };
  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {inherit system;};
  in {
    apps.${system} = {
      install-system = {
        type = "app";
        program = "${inputs.resources.install-system}/bin/install-system";
      };
      install-home = {
        type = "app";
        program = "${inputs.resources.install-home}/bin/install-home";
      };
    };
    nixosSystem = args: {
      nixosConfigurations = {
        "${args.name}" = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {inputs = inputs // (args.inputs or {});};
          modules = [
            {
              networking.hostName = "${args.name}";
              system.stateVersion = "${args.foundation.system}";
              home-manager.sharedModules = [{home.stateVersion = "${args.foundation.homes}";}];
              imports =
                [
                  ./nixos
                  args.hardware
                ]
                ++ (args.imports or []);
            }
          ];
        };
      };
    };
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nixd
        alejandra

        color-lsp

        package-version-server

        vscode-langservers-extracted

        superhtml
        basedpyright
        ruff
        (python313.withPackages (ps: with ps; [terminaltexteffects]))
      ];
    };
  };
}
