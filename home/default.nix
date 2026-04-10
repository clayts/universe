{
  pkgs,
  style,
  lib,
  config,
  ...
}: {
  imports = [
    ./earthpaper
    ./zsh
    ./firefox.nix
    ./ghostty.nix
    ./gnome.nix
    ./zeditor.nix
  ];
  home.packages = with pkgs;
    [
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
    ]
    ++ [
      style.fonts.sans.package
      style.fonts.serif.package
      style.fonts.mono.package
      style.fonts.emoji.package
    ];
  home.stateVersion = "26.05";
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      download = "${config.home.homeDirectory}/Desktop";
      templates = "${config.home.homeDirectory}/.Templates";
      publicShare = "${config.home.homeDirectory}/.Public";
      documents = "${config.home.homeDirectory}/Documents";
      music = "${config.home.homeDirectory}/Media";
      pictures = "${config.home.homeDirectory}/Media";
      videos = "${config.home.homeDirectory}/Media";
    };
  };
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [style.fonts.sans.name "Noto Sans"];
      serif = [style.fonts.serif.name "Noto Serif"];
      monospace = [style.fonts.mono.name "Noto Mono"];
      emoji = [style.fonts.emoji.name "Noto Color Emoji"];
    };
    configFile.features = {
      enable = true;
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <description>Set features</description>
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (
            role: font:
              if font.features == []
              then ""
              else ''
                <match target="font">
                  <test name="family" compare="eq">
                    <string>${font.name}</string>
                  </test>
                  <edit name="fontfeatures" mode="append">
                    ${lib.concatMapStrings (f: "<string>${f} on</string>") font.features}
                  </edit>
                </match>''
          )
          style.fonts)}
        </fontconfig>
      '';
    };
  };
}
