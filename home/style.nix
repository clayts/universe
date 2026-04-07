pkgs: {
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
      name = "Maple Mono";
      size = 10;
      package = pkgs.maple-mono.opentype;
      features = ["calt" "cv02" "cv01" "cv65" "cv66" "ss03" "ss06" "ss11"];
    };
    emoji = {
      name = "Noto Color Emoji";
      size = 10;
      package = pkgs.noto-fonts-color-emoji;
      features = [];
    };
  };
  colors = [
    "#000000" # black
    "#c01c28" # red
    "#10a793" # green
    "#f29c14" # yellow
    "#1e78e4" # blue
    "#9841bb" # purple
    "#10b0da" # cyan
    "#86878b" # white
    "#618399" # bright-black
    "#ee5d43" # bright-red
    "#00e8c6" # bright-green
    "#f5c211" # bright-yellow
    "#7cb7ff" # bright-blue
    "#c74ded" # bright-purple
    "#50ffff" # bright-cyan
    "#f6f5f4" # bright-white
  ];
}
