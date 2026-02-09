{
  pkgs,
  lib,
  inputs,
  ctx,
  ...
}: let
  isLinux = ctx.platform.isLinux or false;
in
  [
    pkgs.htop
    pkgs.fastfetch
    pkgs.tree
    pkgs.yazi
    pkgs.nixpkgs-fmt
    pkgs.kitty
    pkgs.wallust
    pkgs.comma
    pkgs.sshfs
    pkgs.vesktop
  ]
  ++ lib.optionals isLinux [
    inputs.domacro.packages.${pkgs.stdenv.hostPlatform.system}.default
  ]
