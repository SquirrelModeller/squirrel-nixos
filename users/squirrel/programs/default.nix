{ pkgs, inputs }:

with pkgs; [
  hyprpaper
  htop
  grim
  slurp
  wl-clipboard
  fastfetch
  socat
  nixpkgs-fmt
  vlc
  playerctl
  pandoc
  kitty
  inputs.alejandra.defaultPackage.${pkgs.system}
  blender-hip

  (wrapOBS {
    plugins = with obs-studio-plugins; [
      wlrobs
      obs-gstreamer
      obs-pipewire-audio-capture
      obs-vkcapture
    ];
  })
]
