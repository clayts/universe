{
  pkgs,
  lib,
  config,
  ...
}: let
  extensions = with pkgs.gnomeExtensions; [
    grand-theft-focus
    appindicator
    alphabetical-app-grid
    just-perfection
    auto-power-profile
  ];
  packages = with pkgs; [
    gnome-firmware
    loupe
    file-roller
    gnome-calculator
    resources
    gnome-characters
    gnome-logs
    gnome-clocks
    eyedropper
    celluloid
    gitg
    papers
    impression
    baobab
  ];
in {
  home.packages = with pkgs;
    [
      # noto-fonts
      # style.fonts.sans.package
      # style.fonts.serif.package
      # style.fonts.mono.package
      # style.fonts.emoji.package
    ]
    ++ packages;
  # fonts.fontconfig = {
  #   enable = true;
  #   defaultFonts = {
  #     sansSerif = [style.fonts.sans.name "Noto Sans"];
  #     serif = [style.fonts.serif.name "Noto Serif"];
  #     monospace = [style.fonts.mono.name "Noto Mono"];
  #     emoji = [style.fonts.emoji.name "Noto Color Emoji"];
  #   };
  #   configFile.features = {
  #     enable = true;
  #     text = ''
  #       <?xml version="1.0" encoding="UTF-8"?>
  #       <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
  #       <fontconfig>
  #         <description>Set features</description>
  #         ${lib.concatStringsSep "\n" (lib.mapAttrsToList (
  #           role: font:
  #             if font.features == []
  #             then ""
  #             else ''
  #               <match target="font">
  #                 <test name="family" compare="eq">
  #                   <string>${font.name}</string>
  #                 </test>
  #                 <edit name="fontfeatures" mode="append">
  #                   ${lib.concatMapStrings (f: "<string>${f} on</string>") font.features}
  #                 </edit>
  #               </match>''
  #         )
  #         style.fonts)}
  #       </fontconfig>
  #     '';
  #   };
  # };
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
        "file://${config.home.homeDirectory}/Code Code"
        "file://${config.home.homeDirectory}/Desktop Desktop"
        "file://${config.home.homeDirectory}/Documents"
        "file://${config.home.homeDirectory}/Media"
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

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      # font-name = "${style.fonts.sans.name} ${toString style.fonts.sans.size}";
      # document-font-name = "${style.fonts.serif.name} ${toString style.fonts.serif.size}";
      # monospace-font-name = "${style.fonts.mono.name} ${toString style.fonts.mono.size}";
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
    "org/gnome/settings-daemon/plugins/housekeeping".donation-reminder-enabled = false;
    "org/gnome/desktop/peripherals/touchpad".disable-while-typing = false; # Required for touchpad/keyboard games
    "org/gnome/evolution-data-server/calendar".notify-enable-audio = false; # Silences annoying daily beeps
    "org/gnome/settings-daemon/plugins/power".power-button-action = "hibernate";
    "org/gnome/desktop/peripherals/touchpad".speed = 0.1;
    "org/gnome/desktop/peripherals/touchpad".tap-to-click = false;
    "org/gnome/nautilus/icon-view".default-zoom-level = "medium";
    "org/gnome/desktop/background".picture-uri = ".local/share/earthpaper/image.jpeg";
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = true;
    };
    "org/gnome/settings-daemon/plugins/media-keys".play = ["<Super>z"];
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
