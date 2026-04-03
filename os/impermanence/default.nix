{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  environment.persistence."/data" = {
    hideMounts = true;
    directories = [
      "/nix"
      "/var/db"
      "/var/tmp"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/etc/password-files"
      "/etc/nixos"
      "/var/cache"
      "/var/lib"
      "/var/log"
      "/var/spool"
    ];
    files = [
      "/etc/machine-id"
      "/etc/adjtime"
    ];
    users."user" = {
      directories = [
        ".Public"
        {
          directory = ".cache";
          mode = "0700";
        }
        ".local"
        ".mozilla"
        ".nix-defexpr"
        "Desktop"
        "Documents"
        "Media"
      ];
      files = [
        ".config/zsh/.zsh_history"
        {
          file = ".gitconfig";
          parentDirectory = {mode = "0700";};
        }
        {
          file = ".nix-profile";
          parentDirectory = {mode = "0700";};
        }
      ];
    };
  };
  boot.initrd.postResumeCommands =
    lib.mkAfter
    ''
      delete_subvolume() {
       local path=$1
       btrfs subvolume list -o "$path" | cut -f9 -d' ' | tac | while read -r sub; do
       	 btrfs subvolume delete "$path/$sub"
       done
       btrfs subvolume delete "$path"
      }

      mkdir /state
      mount /dev/disk/by-partlabel/disk-main-state /state

      if [[ -f /state/impermanence.conf ]]; then
        while IFS= read -r name; do
          delete_subvolume "/state/$name"
          btrfs subvolume create "/state/$name"
        done < /state/impermanence.conf
      fi

      umount "/state"
    '';
}
