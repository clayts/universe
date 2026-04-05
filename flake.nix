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
    apps.${system} = let
      scan =
        pkgs.writeShellApplication {
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
					              size = \"6G\";
					              content = {
					                type = \"btrfs\";
					                extraArgs = [ \"-f\" ];
													mountpoint = \"/state\";
					                mountOptions = [
					                  \"compress=zstd\"
					                  \"noatime\"
					                ];
													subvolumes.\"@present\" = {
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
        };
    in {
      scan = {
        type = "app";
        program = "${scan}/bin/scan";
      };
      install = {
        type = "app";
        program = "${pkgs.writeShellApplication {
          name = "install";
          runtimeInputs = with pkgs; [nixos-facter jq alejandra];
          text = "
          set -euo pipefail

          if [ \"$#\" -ne 1 ]; then
              echo \"Usage: $0 <hostname>\"
              exit 1
          fi

          ${scan}/bin/scan > /tmp/hardware.nix
          nix run --experimental-features \"nix-command flakes\" github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/hardware.nix
          mkdir -p /mnt/data/etc/nixos/passwords
          echo root
          mkpasswd > /mnt/data/etc/nixos/passwords/root
          echo user
          mkpasswd > /mnt/data/etc/nixos/passwords/user
          echo guest
          mkpasswd > /mnt/data/etc/nixos/passwords/guest
          echo \"{
            inputs.universe.url = \\\"github:clayts/universe\\\";
            outputs = inputs: inputs.universe.system \\\"$1\\\" [./hardware.nix];
          }\" > /mnt/data/etc/nixos/flake.nix
          mv /tmp/hardware.nix /mnt/data/etc/nixos/
          mkdir /mnt/nix
          mkdir /mnt/data/nix
          mount --bind /mnt/data/nix /mnt/nix
          nixos-install --flake /mnt/data/etc/nixos#\"$1\"
          ";
        }}/bin/install";
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
