{
  inputs,
  pkgs,
}:
{
  templates = "${./templates}";
  style = import ./style.nix { inherit pkgs; };
  packages = import ./packages { inherit pkgs inputs; };
}
