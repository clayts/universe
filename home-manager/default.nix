{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  imports = [
    ./firefox.nix
    ./ghostty.nix
    ./gnome.nix
    ./micro.nix
    ./zeditor.nix
    ./zsh.nix
  ];
  home = {
    packages = with pkgs; [
      # GUI
      gnome-firmware
      loupe
      file-roller
      gnome-calculator
      gnome-characters
      gnome-logs
      gnome-clocks
      eyedropper
      celluloid
      gitg
      papers
      impression
      baobab

      # CLI
      grc
      fzf
      lsd
      fd
      git
      gh
    ];
    sessionVariables = {
      EDITOR = "micro";
      GOPATH = "$HOME/.local/share/go";
    };
  };

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
      extraConfig = {
        code = "${config.home.homeDirectory}/Code";
      };
    };
  };
  fonts.fontconfig = {
    enable = true;
    defaultFonts = with inputs.resources.style.fonts; {
      sansSerif = [sans.name "Noto Sans"];
      serif = [serif.name "Noto Serif"];
      monospace = [mono.name "Noto Mono"];
      emoji = [emoji.name "Noto Color Emoji"];
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
          inputs.resources.style.fonts)}
        </fontconfig>
      '';
    };
  };
}
