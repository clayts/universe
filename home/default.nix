{...}: {
  imports = [
    ./zeditor
    ./scripts
    ./zsh
    ./earthpaper
    ./firefox.nix
    ./ghostty.nix
    ./gnome.nix
  ];
  home.stateVersion = "25.05";
}
