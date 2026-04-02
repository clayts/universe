{
  pkgs,
  inputs,
  specialArgs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  environment = {
    localBinInPath = true;
    variables = {
      XDG_CONFIG_HOME = "$HOME/.config";
    };
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
        hashedPasswordFile = "/etc/password-files/user";
      };
      "guest" = {
        description = "Guest";
        isNormalUser = true;
        extraGroups = [];
        hashedPasswordFile = "/etc/password-files/guest";
      };
      "root".hashedPasswordFile = "/etc/password-files/root";
    };
  };
  home-manager = {
    sharedModules = [{home.stateVersion = "25.05";}];
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
    backupFileExtension = "home-manager-backup";
    users =
      (lib.genAttrs ["root" "user" "guest"] (user: {imports = [../home];}));
  };
}
