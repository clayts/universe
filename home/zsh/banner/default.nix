{pkgs, ...}: let
  pythonEnv = pkgs.python313.withPackages (ps:
    with ps; [
      terminaltexteffects
    ]);
in {
  home.packages = [
    (pkgs.writeScriptBin "rizzlefetch" ''
      export PATH=${pkgs.lib.makeBinPath [pkgs.toilet]}:$PATH
      ${pythonEnv}/bin/python ${./rizzlefetch.py}
    '')
  ];
}
