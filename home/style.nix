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
      features = ["calt" "cv02" "cv01" "cv65" "cv66" "ss03" "ss06" "ss10" "ss09" "ss11"];
    };
    emoji = {
      name = "Noto Color Emoji";
      size = 10;
      package = pkgs.noto-fonts-color-emoji;
      features = [];
    };
  };
}
