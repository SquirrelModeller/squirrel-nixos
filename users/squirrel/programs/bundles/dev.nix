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
    pkgs.socat
    pkgs.pandoc
    pkgs.nixpkgs-fmt
    pkgs.nixfmt
    pkgs.alejandra
  ]
  ++ lib.optionals isLinux [
    pkgs.blender
    pkgs.tofi
  ]
