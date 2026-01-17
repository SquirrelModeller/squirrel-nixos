{ pkgs, lib, inputs, ... }:
[
  pkgs.socat
  pkgs.pandoc
  pkgs.pkgsRocm.blender
  pkgs.tofi
  inputs.alejandra.defaultPackage.${pkgs.stdenv.hostPlatform.system}
]
