{
  lib,
  inputs,
  ...
}: {
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
    users."guest" = {
      directories = [
        ".local/share/earthpaper"
      ];
    };
    users."user" = {
      directories = [
        ".Public"
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
      ];
      files = [
        {
          file = ".gitconfig";
          method = "symlink";
        }
        ".nix-profile"
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

  # boot.initrd.postResumeCommands =
  #   lib.mkAfter
  #   ''
  #     delete_subvolume() {
  #      local path=$1
  #      btrfs subvolume list -o "$path" | cut -f9 -d' ' | tac | while read -r sub; do
  #      	 btrfs subvolume delete "$path/$sub"
  #      done
  #      btrfs subvolume delete "$path"
  #     }

  #     mkdir /state
  #     mount /dev/disk/by-partlabel/disk-main-state /state

  #     if [[ -f /state/impermanence.conf ]]; then
  #       while IFS= read -r name; do
  #         delete_subvolume "/state/$name"
  #         btrfs subvolume create "/state/$name"
  #       done < /state/impermanence.conf
  #     fi

  #     umount "/state"
  #   '';
}
