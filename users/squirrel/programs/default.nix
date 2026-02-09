{
  pkgs,
  lib,
  ctx,
  inputs,
  ...
}:
with lib; let
  B = name: import ./bundles/${name}.nix {inherit pkgs lib inputs ctx;};
  wantsWayland = ctx.capabilities.graphical && ctx.platform.isLinux;
in
  B "base"
  ++ B "dev"
  ++ B "media"
  ++ optionals wantsWayland (B "wayland")
