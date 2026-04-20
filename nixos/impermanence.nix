{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
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
      ];
      files = [
        {
          file = ".config/gh/hosts.yml";
          parentDirectory = {mode = "0751";};
        }
        {
          file = ".gitconfig";
          method = "symlink";
        }
        {
          file = ".config/goa-1.0/accounts.conf";
          method = "symlink";
        }
      ];
    };
  };
  system.activationScripts.fix-config-files = {
    text = ''
      touch /data/home/user/.config/goa-1.0/accounts.conf
      touch /data/home/user/.gitconfig
    '';
  };
}
