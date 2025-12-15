{ pkgs, lib, inputs, ... }:
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
  inputs.domacro.packages.${pkgs.stdenv.hostPlatform.system}.default
]

