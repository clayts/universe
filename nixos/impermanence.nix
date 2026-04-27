{ inputs, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=32M"
      "mode=755"
    ];
  };
  environment.persistence."/data" = {
    allowTrash = true;
    hideMounts = true;
    directories = [
      "/nix/"
      "/var/"
      "/etc/NetworkManager/system-connections/"
      "/etc/ssh/"
      "/etc/nixos/"
    ];
    files = [
      "/etc/machine-id"
      "/etc/adjtime"
    ];
    users."user" = {
      directories = [
        "Desk/"
        "Media/"
        "Works/"

        ".steam/"
        ".Public/"
        ".local/state/comma/"
        ".local/state/zsh/"
        ".local/state/wireplumber/"
        ".local/share/Trash/"
        ".local/share/cryfs/"
        ".local/share/dbus-1/"
        ".local/share/direnv/"
        ".local/share/earthpaper/"
        ".local/share/evolution/"
        ".local/share/gnome-settings-daemon/"
        ".local/share/gnome-shell/"
        ".local/share/gvfs-metadata/"
        ".local/share/icc/"
        ".local/share/keyrings/"
        ".local/share/nautilus/"
        ".local/share/pki/"
        ".local/share/safe/"
        ".local/share/zed/"
        ".local/share/zoxide/"
        ".config/mozilla/"
        ".config/goa-1.0/"
        {
          directory = ".cache/";
          mode = "0700";
        }
        {
          directory = ".config/gh/";
          mode = "0751";
        }
      ];
      files = [
        ".local/share/recently-used.xbel"
        {
          file = ".gitconfig";
          method = "symlink";
        }
      ];
    };
  };
  system.activationScripts.fix-config-files = {
    text = ''
      touch /data/home/user/.gitconfig
    '';
  };
}
