{ pkgs }:
{
  fonts = import ./fonts.nix { inherit pkgs; };
  colors = builtins.fromJSON (builtins.readFile ./colors.json);
  icons = {
    name = "MoreWaita";
    package = pkgs.morewaita-icon-theme;
  };
  cursors = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
  };
}
