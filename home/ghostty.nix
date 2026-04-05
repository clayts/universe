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
          "0=#000000"
          "1=#c01c28"
          "2=#00E8C6"
          "3=#f5c211"
          "4=#1e78e4"
          "5=#9841bb"
          "6=#00afff"
          "7=#86878b"
          "8=#10a793"
          "9=#ee5d43"
          "10=#57e389"
          "11=#f29c14"
          "12=#7cb7ff"
          "13=#c74ded"
          "14=#00e8c6"
          "15=#f6f5f4"
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
