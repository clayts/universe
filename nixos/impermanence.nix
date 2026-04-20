{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=64M" "mode=755"];
  };
  environment.persistence."/data" = {
    allowTrash = true;
    hideMounts = true;
    directories = [
      "/nix"
      "/var"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/etc/nixos"
    ];
    files = [
      "/etc/machine-id"
      "/etc/adjtime"
    ];
    users."user" = {
      directories = [
        {
          directory = ".cache";
          mode = "0700";
        }
        ".local"
        ".mozilla"
        ".steam"
        "Desktop"
        "Documents"
        "Media"
        "Code"
        ".Public"

        {
          directory = ".config/gh";
          mode = "0751";
        }
        ".config/goa-1.0"
      ];
      files = [
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
