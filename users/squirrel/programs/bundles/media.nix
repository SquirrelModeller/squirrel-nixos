{ pkgs, lib, ctx, ... }:
let
  isLinux = ctx.platform.isLinux or false;
in
[
] ++ lib.optionals isLinux [
  (pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-gstreamer
      obs-pipewire-audio-capture
      obs-vkcapture
    ];
  })
  pkgs.vlc
]