{ pkgs, lib, ... }:
[
  pkgs.vlc
  pkgs.playerctl
  (pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-gstreamer
      obs-pipewire-audio-capture
      obs-vkcapture
    ];
  })
]
