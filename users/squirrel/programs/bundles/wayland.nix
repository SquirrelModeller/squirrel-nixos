{ pkgs, lib, inputs, ... }:
[
  pkgs.hyprpaper
  pkgs.hypridle
  pkgs.hyprlock
  pkgs.grim
  pkgs.slurp
  pkgs.wl-clipboard
  pkgs.playerctl
  pkgs.capitaine-cursors
  inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
]
