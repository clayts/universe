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
      url = "path:./resources";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {inherit system;};
  in {
    home = name: initialRelease: modules: {
      homeManagerConfigurations = {
        ${name} = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs;};
          modules = [./home-manager] ++ modules;
        };
      };
    };
    apps.${system} = {
      scan-hardware = {
        type = "app";
        program = "${inputs.resources.scan-hardware}/bin/scan-hardware";
      };
      install-system = {
        type = "app";
        program = "${inputs.resources.install-system}/bin/install-system";
      };
    };
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nixd
        alejandra
        package-version-server
        vscode-langservers-extracted
        superhtml
        basedpyright
        python313Packages.terminaltexteffects
        toilet
        ruff
      ];
    };
  };
}
