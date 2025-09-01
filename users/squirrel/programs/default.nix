{ pkgs, lib, ctx, inputs, ... }:
with lib;
let
  B = name: import ./bundles/${name}.nix { inherit pkgs lib inputs; };
  wantsWayland = ctx.capabilities.graphical && ctx.platform.isLinux;
in
B "base"
++ B "dev"
++ B "editors/emacs"
++ optionals wantsWayland (B "wayland")
++ optionals wantsWayland (B "media") #temp using wayland
