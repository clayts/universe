{
  pkgs,
  inputs,
  specialArgs,
  lib,
  ...
}: {
  environment = {
    localBinInPath = true;
    variables = {
      XDG_CONFIG_HOME = "$HOME/.config";
    };

    # [TODO]
    # move to home manager?
    etc."xdg/user-dirs.defaults".text = ''
      DESKTOP=Desktop
      DOWNLOAD=Desktop
      TEMPLATES=.Templates
      PUBLICSHARE=.Public
      DOCUMENTS=Documents
      MUSIC=Media
      PICTURES=Media
      VIDEOS=Media
    '';
  };
  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users = {
      "user" = {
        description = "User";
        isNormalUser = true;
        extraGroups = ["wheel" "libvirtd" "networkmanager"];
        hashedPasswordFile = "/data/etc/nixos/passwords/user";
      };
      "guest" = {
        description = "Guest";
        isNormalUser = true;
        extraGroups = [];
        hashedPasswordFile = "/data/etc/nixos/passwords/guest";
      };
      "root".hashedPasswordFile = "/data/etc/nixos/passwords/root";
    };
  };

  imports = [
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    # useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
    backupFileExtension = "home-manager-backup";
    users =
      lib.genAttrs ["root" "user" "guest"] (user: {imports = [../home];});
  };
}
