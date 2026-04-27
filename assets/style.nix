{ pkgs, ... }:
{
  icons = {
    name = "MoreWaita";
    package = pkgs.morewaita-icon-theme;
  };
  cursors = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
  };
  fonts = {
    sans = {
      name = "DeepMind Sans Medium";
      size = 11;
      package = pkgs.dm-sans;
      features = [ ];
    };
    serif = {
      name = "Libre Baskerville";
      size = 10;
      package = pkgs.libre-baskerville;
      features = [ ];
    };
    mono = {
      name = "Maple Mono NF";
      size = 10;
      package = pkgs.maple-mono.NF;
      features = [
        "calt"
        "cv02"
        "cv01"
        "cv65"
        "cv66"
        "ss03"
        "ss06"
        "ss11"
      ];
    };
    emoji = {
      name = "Noto Color Emoji";
      size = 10;
      package = pkgs.noto-fonts-color-emoji;
      features = [ ];
    };
  };
  colors = {
    x0 = "#1D1D20"; # Dark
    x1 = "#222226";
    x2 = "#2e2e32";
    x3 = "#777777";
    x4 = "#909999";
    x5 = "#c0cccc";
    x6 = "#d0dddd";
    x7 = "#e0eeee"; # Light

    x8 = "#ed5b00"; # Red #ff5370
    x9 = "#ffd157"; # Yellow
    xA = "#ff9000"; # Gold #ed5b00
    xB = "#2df4a0"; # Green
    xC = "#40efff"; # Cyan
    xD = "#41bbff"; # Blue
    xE = "#9F46F6"; # Purple
    xF = "#f0ffff"; # White
  };
}
