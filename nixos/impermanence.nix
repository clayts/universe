{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  environment.persistence."/system/data" = {
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
    users."guest" = {
      directories = [
        ".local/share/earthpaper"
      ];
    };
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
          file = ".gitconfig";
          method = "symlink";
        }
        {
          file = ".config/gh/hosts.yml";
          parentDirectory = {mode = "0751";};
        }
      ];
    };
  };

  boot.initrd.systemd.services.create-state = {
    description = "Create system state";
    wantedBy = ["initrd.target"];
    after = ["initrd-root-device.target"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = inputs.resources.create-state-script;
  };
}
