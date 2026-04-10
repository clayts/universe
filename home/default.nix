{
  pkgs,
  style,
  lib,
  ...
}: {
  imports = [
    ./earthpaper
    ./scripts
    ./zeditor
    ./zsh
    ./firefox.nix
    ./ghostty.nix
    ./gnome.nix
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
  home.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;
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
