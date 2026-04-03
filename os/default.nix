{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.default
    ./users.nix
    ./desktop.nix
    ./hardware.nix
    ./impermanence
  ];
  environment.systemPackages = with pkgs; [
    (aspellWithDicts (dicts: [
      dicts.en
      dicts.en-computers
      dicts.en-science
    ]))
    android-tools
  ];
  virtualisation.libvirtd.enable = true;
  system.stateVersion = "24.11";
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
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    plymouth.enable = true;
    initrd.verbose = false;
    consoleLogLevel = 0;
  };
  console.keyMap = "uk";
  services = {
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
    virt-manager.enable = true;
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
    package = pkgs.lixPackageSets.stable.lix;
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    settings.experimental-features = ["nix-command" "flakes"];
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
    };
    overlays = [
      (final: prev: {
        inherit (prev.lixPackageSets.stable) nixpkgs-review nix-eval-jobs nix-fast-build colmena;
      })
    ];
  };
  hardware.enableAllFirmware = true;
  networking.networkmanager.enable = true;
}
