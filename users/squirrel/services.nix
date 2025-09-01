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

}

