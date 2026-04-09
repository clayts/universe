{inputs, ...}: {
  # imports = [inputs.stylix.homeModules.stylix];
  stylix = {
    targets = {
      fontconfig.enable = true;
      firefox = {
        enable = true;
        firefoxGnomeTheme.enable = true;
        colors.enable = false;
        profileNames = ["default"];
      };
      font-packages.enable = true;
      fzf.enable = true;
      ghostty.enable = true;
      gnome-text-editor.enable = true;
      gnome = {
        enable = true;
        fonts.enable = true;
        colors.enable = false;
      };
      gtk = {
        enable = true;
        colors.enable = false;
        fonts.enable = true;
      };
      gtksourceview.enable = true;
      micro.enable = true;
      zed = {
        enable = true;
        inputs.override = {
          tinted-zed = ./zeditor;
        };
      };
    };
  };
}
