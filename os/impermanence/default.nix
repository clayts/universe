{
  config,
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
      "/var/db"
      "/var/tmp"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/etc/password-files"
    ];
    files = [
      "/etc/machine-id"
      "/etc/adjtime"
    ];
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
      mount ${config.fileSystems."/state".device} /state

      if [[ -f /state/impermanence.conf ]]; then
        while IFS= read -r name; do
          delete_subvolume "/state/$name"
          btrfs subvolume create "/state/$name"
        done < /state/impermanence.conf
      fi

      umount "/state"
    '';
}
