{
  pkgs,
  inputs,
  ...
}: let
  qtPinnedPkgs = import inputs.nixpkgs-qtpin {system = pkgs.system;};
in {
  environment.systemPackages = with pkgs; [
    nil
    nixpkgs-fmt
    qtPinnedPkgs.qt6.qtdeclarative
    vscodium
  ];
}
