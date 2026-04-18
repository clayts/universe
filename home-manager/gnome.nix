{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  extensions = with pkgs.gnomeExtensions; [
    grand-theft-focus
    appindicator
    alphabetical-app-grid
    just-perfection
    auto-power-profile
  ];
in {
  home = {
    packages = with inputs.resources.style.fonts; [sans.package serif.package mono.package emoji.package];
    activation.initialWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f ${config.home.homeDirectory}/.local/share/earthpaper/image.jpeg ]; then
        mkdir -p ${config.home.homeDirectory}/.local/share/earthpaper
        ln -s \
          ${pkgs.nixos-artwork.wallpapers.simple-blue}/share/wallpapers/simple-blue/contents/images/nix-wallpaper-simple-blue.png \
          ${config.home.homeDirectory}/.local/share/earthpaper/image.jpeg
      fi
    '';
  };
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.morewaita-icon-theme;
      name = "MoreWaita";
    };
    gtk4.theme = null;
    gtk3 = {
      theme = {
        name = "adw-gtk3";
        package = pkgs.adw-gtk3;
      };
      bookmarks = [
        "file://${config.home.homeDirectory}/Documents"
        "file://${config.home.homeDirectory}/Media"
        "file://${config.home.homeDirectory}/Desktop Desktop"
        "file://${config.home.homeDirectory}/Code Code"
        "file:///system System"
      ];
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };
  programs.gnome-shell = {
    enable = true;
    extensions = map (extension: {package = extension;}) extensions;
  };
  systemd.user = {
    services.earthpaper-switcher = {
      Unit = {
        Description = "Service for earthpaper-switcher";
        StartLimitBurst = 12; # Maximum retries (12*5=60 mins)
      };
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "earthpaper-switcher" ''
          if [ -h ~/.local/share/earthpaper/image.jpeg ]; then
              rm ~/.local/share/earthpaper/image.jpeg
          fi
          ${inputs.resources.earthpaper}/bin/earthpaper ~/.local/share/earthpaper/image.jpeg
        '';
        Restart = "on-failure";
        RestartSec = 300; # seconds between retries (5 mins)
      };
    };
    timers.earthpaper-switcher = {
      Unit.Description = "Timer for earthpaper-switcher";
      Timer = {
        Unit = "earthpaper-switcher.service";
        OnCalendar = "daily";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = with inputs.resources.style.fonts; {
      font-name = "${sans.name} ${toString sans.size}";
      document-font-name = "${serif.name} ${toString serif.size}";
      monospace-font-name = "${mono.name} ${toString mono.size}";
      gtk-enable-primary-paste = false; # Disable middle-click paste as it can accidentally paste stuff when scrolling
      enable-hot-corners = false;
      font-antialiasing = "greyscale";
      font-hinting = "slight";
    };
    "org/gnome/shell".disable-user-extensions = false;
    "org/gnome/shell".enabled-extensions =
      map (extension: extension.extensionUuid)
      extensions;
    "org/gnome/shell/extensions/just-perfection" = {
      panel = false;
      panel-in-overview = true;
      activities-button = false;
      quick-settings-dark-mode = false;
      quick-settings-night-light = false;
      quick-settings-airplane-mode = false;
      window-preview-caption = false;
      background-menu = false;
      support-notifier-showed-version = pkgs.gnomeExtensions.just-perfection.version;
      support-notifier-type = 0;
    };
    "org/gnome/shell".favorite-apps = [
      "firefox.desktop"
      "org.gnome.Nautilus.desktop"
    ];
    "org/gnome/shell/window-switcher".current-workspace-only = false;
    "org/gnome/settings-daemon/plugins/housekeeping".donation-reminder-enabled = false;
    "org/gnome/desktop/peripherals/touchpad".disable-while-typing = false; # Required for touchpad/keyboard games
    "org/gnome/evolution-data-server/calendar".notify-enable-audio = false; # Silences annoying daily beeps
    "org/gnome/settings-daemon/plugins/power".power-button-action = "hibernate";
    "org/gnome/desktop/peripherals/touchpad".speed = 0.1;
    "org/gnome/desktop/peripherals/touchpad".tap-to-click = false;
    "org/gnome/nautilus/icon-view".default-zoom-level = "medium";
    "org/gnome/desktop/background".picture-uri = "${config.home.homeDirectory}/.local/share/earthpaper/image.jpeg";
    "org/gnome/nautilus/list-view".use-tree-view = true;
    "org/gnome/nautilus/preferences".show-delete-permanently = true;
    "org/gnome/desktop/privacy".remove-old-trash-files = true;
    "org/gnome/desktop/privacy".old-files-age = lib.gvariant.mkUint32 1;
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = true;
    };
    "org/gnome/settings-daemon/plugins/media-keys".play = ["<Shift><Super>F23"];
    "org/gnome/desktop/wm/keybindings" = {
      toggle-fullscreen = ["<Super>f"];
      close = ["<Super>q"];
      switch-windows = ["<Super>Tab"];
      switch-windows-backward = ["<Shift><Super>Tab"];
      switch-applications = ["<Alt>Tab"];
      switch-applications-backward = ["<Shift><Alt>Tab"];
    };
    "org/gnome/desktop/app-folders" = {
      folder-children = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
    };
  };
}
