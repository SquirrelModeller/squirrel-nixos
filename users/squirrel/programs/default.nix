{
  pkgs,
  lib,
  ctx,
  inputs,
  ...
}:
with lib; let
  B = name: import ./bundles/${name}.nix {inherit pkgs lib inputs ctx;};
  isGraphical = ctx.capabilities.graphical;
  wantsWayland = isGraphical && ctx.platform.isLinux;
in
  optionals isGraphical (
    B "base"
    ++ B "dev"
    ++ B "media"
    ++ optionals wantsWayland (B "wayland")
  )
