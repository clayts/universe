pkgs: {
  fonts = {
    sans = {
      name = "DM Sans";
      size = 10;
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
      features = ["calt" "cv02"];
    };
    emoji = {
      name = "Noto Color Emoji";
      size = 10;
      package = pkgs.noto-fonts-color-emoji;
      features = [];
    };
  };
}
