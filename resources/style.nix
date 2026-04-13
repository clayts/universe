{pkgs, ...}: {
  fonts = {
    sans = {
      name = "DeepMind Sans Medium";
      size = 11;
      package = pkgs.dm-sans;
      features = [];
    };
    serif = {
      name = "Merriweather";
      size = 10;
      package = pkgs.merriweather;
      features = [];
    };
    mono = {
      name = "Maple Mono NF";
      size = 10;
      package = pkgs.maple-mono.NF;
      features = ["calt" "cv02" "cv01" "cv65" "cv66" "ss03" "ss06" "ss11"];
    };
    emoji = {
      name = "Noto Color Emoji";
      size = 10;
      package = pkgs.noto-fonts-color-emoji;
      features = [];
    };
  };
  colors = {
    x0 = "#1D1D20"; # Dark
    x1 = "#222226"; #
    x2 = "#2e2e32"; #
    x3 = "#777777"; #
    x4 = "#909999"; #
    x5 = "#c0cccc"; #
    x6 = "#d0dddd"; #
    x7 = "#e0eeee"; # Light

    x8 = "#ff5370"; # Red
    x9 = "#ffd157"; # Yellow
    xA = "#ff9000"; # Gold
    xB = "#2df4a0"; # Green
    xC = "#40efff"; # Cyan
    xD = "#41bbff"; # Blue
    xE = "#e012be"; # Purple
    xF = "#f0ffff"; # White
  };
}
