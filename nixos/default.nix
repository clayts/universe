{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./gnome.nix
    ./hardware.nix
    ./impermanence.nix
    ./users.nix
  ];
  environment.systemPackages = with pkgs; [
    inputs.resources.persist
    inputs.resources.system
    inputs.resources.scan-hardware
    (aspellWithDicts (dicts: [
      dicts.en
      dicts.en-computers
      dicts.en-science
    ]))
    android-tools
  ];
  virtualisation.libvirtd.enable = true;
  boot = {
    tmp.useTmpfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    kernel.sysctl = {"vm.swappiness" = 10;};
    loader = {
      systemd-boot.enable = true;
      efi = {
        efiSysMountPoint = "/system/boot";
        canTouchEfiVariables = true;
      };
      timeout = 0;
    };
    plymouth.enable = true;
    initrd.verbose = false;
    consoleLogLevel = 0;
  };
  time.timeZone = "Europe/London";
  console.useXkbConfig = true;
  services = {
    xserver.xkb.layout = "gb";
    logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    ipp-usb.enable = true;
    fwupd.enable = true;
    printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
    };
  };
  systemd.sleep.settings.Sleep.HibernateDelaySec = "48h";
  programs = {
    zsh.enable = true;
    nh.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
  security = {
    sudo = {
      wheelNeedsPassword = false;
      extraConfig = ''Defaults:root,%wheel env_keep+=SHLVL'';
    };
    rtkit.enable = true;
  };
  documentation.nixos.enable = false;
  nix = {
    enable = true;
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    settings = {
      download-buffer-size = 256 * 1024 * 1024;
      experimental-features = ["nix-command" "flakes"];
    };
  };
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  networking.networkmanager.enable = true;
}
