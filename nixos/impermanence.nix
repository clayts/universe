{
  lib,
  inputs,
  ...
}: {
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

  boot.initrd.postResumeCommands =
    lib.mkAfter
    ''
      mkdir /state
      mount /dev/disk/by-partlabel/disk-main-state /state
      if [[ -e /state/@present ]]; then
          timestamp=$(date --date="@$(stat -c %Y /state/@present)" "+%Y-%m-%-d_%H:%M:%S")
          mv /state/@present "/state/@$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/state/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /state/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /state/@present
      umount /state
    '';
}
