{ pkgs, lib, inputs, ... }:
[
  pkgs.hyprpaper
  pkgs.grim
  pkgs.slurp
  pkgs.wl-clipboard
  inputs.quickshell.packages.${pkgs.system}.default
]

