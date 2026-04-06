{pkgs, ...}: let
  style = import ./style.nix pkgs;
in {
  # This allows gnome to use ghostty as a default terminal when running
  # .desktop files that require a terminal
  home.packages = [(pkgs.writeShellScriptBin "xterm" ''${pkgs.ghostty} $*'')];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    systemd.enable = true;
    themes = {
      "Custom" = {
        background = "000000";
        cursor-color = "ffffff";
        foreground = "ffffff";
        palette = [
          "0=#000000" # black
          "1=#c01c28" # red
          "2=#10a793" # green
          "3=#f29c14" # yellow
          "4=#1e78e4" # blue
          "5=#9841bb" # purple
          "6=#10b0da" # cyan
          "7=#86878b" # white
          "8=#618399" # bright-black
          "9=#ee5d43" # bright-red
          "10=#00e8c6" # bright-green
          "11=#f5c211" # bright-yellow
          "12=#7cb7ff" # bright-blue
          "13=#c74ded" # bright-purple
          "14=#50ffff" # bright-cyan
          "15=#f6f5f4" # bright-white
        ];
        selection-background = "ffffff";
        selection-foreground = "5e5c64";
      };
    };
    settings = {
      keybind = [
        "ctrl+c=copy_to_clipboard"
        "ctrl+v=paste_from_clipboard"
        ''ctrl+k=text:\x03''
      ];
      font-family = [
        style.fonts.mono.name
        style.fonts.emoji.name
      ];
      font-size = style.fonts.mono.size;
      adjust-cell-height = -2;
      font-feature = style.fonts.mono.features;
      # theme = "${./theme}";
      theme = "Custom";
      command = "SHLVL=0; zsh";
      window-theme = "ghostty";
      adw-toolbar-style = "raised";
      window-padding-x = 11;
      window-padding-y = 3;
      confirm-close-surface = false;
      window-width = 80;
      window-height = 32;
    };
  };
}
