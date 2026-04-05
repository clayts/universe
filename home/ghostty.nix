{pkgs, ...}: let
  style = import ./style.nix pkgs;
in {
  # This allows gnome to use ghostty as a default terminal when running
  # .desktop files that require a terminal
  home.packages = [(pkgs.writeShellScriptBin "xterm" ''${pkgs.ghostty} $*'')];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
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
      theme = "Adwaita Dark"; # ghostty +list-themes
      background = "#000000";
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
