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
  };
  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    resources = import ./resources {inherit pkgs;};
  in {
    system = hostName: modules: {
      nixosConfigurations = {
        ${hostName} = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs resources;};
          modules = [./nixos {networking = {inherit hostName;};}] ++ modules;
        };
      };
    };
    home = name: modules: {
      homeManagerConfigurations = {
        ${name} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs resources;};
          modules = [./home-manager] ++ modules;
        };
      };
    };
    apps.${system} = {
      scan = {
        type = "app";
        program = "${resources.scan}/bin/scan";
      };
      install = {
        type = "app";
        program = "${resources.install}/bin/install";
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
        (pkgs.writeShellScriptBin "switch-test" ''nh os switch /etc/nixos -- --override-input universe path:.'')
      ];
    };
  };
}
