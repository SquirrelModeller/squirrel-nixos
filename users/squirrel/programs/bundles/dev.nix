{ pkgs, lib, inputs, ... }:
[
  pkgs.socat
  pkgs.pandoc
  pkgs.blender-hip
  pkgs.tofi
  inputs.alejandra.defaultPackage.${pkgs.stdenv.hostPlatform.system}
]
