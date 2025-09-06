{ pkgs, username, ... }:
let
  hyprpaper = pkgs.hyprpaper;
in
{
  "ui-hyprpaper-${username}" = {
    description = "Hyprpaper for ${username}";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    unitConfig.ConditionUser = username;
    path = [ hyprpaper ];
    serviceConfig = {
      ExecStart = "${hyprpaper}/bin/hyprpaper";
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  "hypridle-${username}" = {
    description = "Hypridle for ${username}";
    wantedBy = [ "wayland-session-xdg-autostart@Hyprland.target" ];
    after = [ "wayland-session-xdg-autostart@Hyprland.target" ];
    unitConfig.ConditionUser = username;

    path = [ pkgs.hyprland pkgs.hyprlock pkgs.procps pkgs.coreutils pkgs.util-linux pkgs.systemd ];

    serviceConfig = {
      ExecStart = "${pkgs.hypridle}/bin/hypridle";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

}

