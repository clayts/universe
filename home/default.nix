{...}: {
  imports = [
    ./earthpaper
    ./scripts
    ./stylix
    ./zeditor
    ./zsh
    ./firefox.nix
    ./ghostty.nix
    ./gnome.nix
  ];
  home.stateVersion = "25.05";
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      (final: prev: {
        inherit (prev.lixPackageSets.stable) nixpkgs-review nix-eval-jobs nix-fast-build colmena;
      })
    ];
  };
}
