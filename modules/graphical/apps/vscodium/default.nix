{
  pkgs,
  inputs,
  ...
}: let
  qtPinnedPkgs = import inputs.nixpkgs-qtpin {inherit (pkgs) system;};
in {
  environment.systemPackages = with pkgs; [
    nil
    nixpkgs-fmt
    qtPinnedPkgs.qt6.qtdeclarative
    vscodium
  ];
}
