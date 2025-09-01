{ pkgs, lib, inputs, ... }:
[
  pkgs.hyprpaper
  pkgs.grim
  pkgs.slurp
  pkgs.wl-clipboard
  pkgs.playerctl
  pkgs.capitaine-cursors
  inputs.quickshell.packages.${pkgs.system}.default
]

