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
  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {inherit system;};
  in {
    system = name: modules: {
      nixosConfigurations = {
        ${name} = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [./os {networking.hostName = name;}] ++ modules;
        };
      };
    };
    home = name: modules: {
      homeManagerConfigurations = {
        ${name} = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {inherit inputs;};
          modules = [./home] ++ modules;
        };
      };
    };
    apps.${system} = {
      scan = {
        type = "app";
        program = "${pkgs.writeShellApplication {
            name = "scan";
            runtimeInputs = with pkgs; [nixos-facter jq alejandra];
            text = "
            	report=$(nixos-facter | jq '.hardware.disk |= map(select(.class_list | contains([\"usb\"]) | not))')
							disk=$(echo \"$report\" | jq -r '
								[ .hardware.disk[].unix_device_names
								    | map(select(contains(\"/dev/disk/by-id/\")))
								    | max_by(length) // empty ]
								| if length == 1 then .[0] else \"\" end
							')
							swap=$(free -m | awk '/^Mem:/{print $2 * 2}')M
              alejandra -q <<-EOF
							{...}: {
								fileSystems.\"/data\".neededForBoot = true;
								disko.devices.disk.main = {
					        device = \"$disk\";
					        type = \"disk\";
					        content = {
					          type = \"gpt\";
					          partitions = {
					            boot = {
					              type = \"EF00\";
					              size = \"2G\";
					              content = {
					                type = \"filesystem\";
					                format = \"vfat\";
					                mountpoint = \"/boot\";
					                mountOptions = [\"umask=0077\"];
					              };
					            };
					            state = {
					              size = \"8G\";
					              content = {
					                type = \"btrfs\";
					                extraArgs = [ \"-f\" ];
					                mountOptions = [
					                  \"compress=zstd\"
					                  \"noatime\"
					                ];
													subvolumes.\"@root\" = {
														mountpoint = \"/\";
														mountOptions = [
														\"compress=zstd\"
														\"noatime\"
														];
													};
					              };
					            };
					            data = {
					              size = \"100%\";
					              content = {
					                type = \"filesystem\";
					                format = \"xfs\";
					                mountpoint = \"/data\";
					              };
					            };
					            swap = {
					              size = \"$swap\";
					              content = {
					                type = \"swap\";
					                discardPolicy = \"both\";
					                resumeDevice = true;
					              };
					            };
					          };
					        };
					      };
								hardware.facter.reportPath = builtins.toFile \"hardware.json\" ''
									$report
								'';
							}
							EOF
							";
          }}/bin/scan";
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
