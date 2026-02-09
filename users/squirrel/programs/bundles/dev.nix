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
  ]
  ++ lib.optionals isLinux [
    pkgs.blender
    pkgs.tofi
    inputs.alejandra.defaultPackage.${pkgs.stdenv.hostPlatform.system}
  ]
