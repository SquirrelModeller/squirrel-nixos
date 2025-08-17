{ pkgs, username, inputs, ... }:
let
  hyprpaper = pkgs.hyprpaper;
  quickshell = inputs.quickshell.packages.${pkgs.system}.default;
in
{
  "ui-quickshell-${username}" = {
    description = "Quickshell for ${username}";
    after = [ "graphical-session.target" "hyprland-session.target" ];
    partOf = [ "graphical-session.target" "hyprland-session.target" ];
    requires = [ "hyprland-session.target" ];
    wantedBy = [ "hyprland-session.target" ];
    unitConfig.ConditionUser = username;

    path = [ quickshell ];
    serviceConfig = {
      # Run in foreground so Type=simple works
      ExecStart = "${quickshell}/bin/quickshell";
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;

      EnvironmentFile = "-/etc/environment";
      PassEnvironment = "PATH";
      Environment = [
        "XDG_RUNTIME_DIR=%t"
        "WAYLAND_DISPLAY=wayland-1"
      ];
    };
  };

  "ui-hyprpaper-${username}" = {
    description = "Hyprpaper for ${username}";
    after = [ "graphical-session.target" "hyprland-session.target" ];
    partOf = [ "graphical-session.target" "hyprland-session.target" ];
    requires = [ "hyprland-session.target" ];
    wantedBy = [ "hyprland-session.target" ];
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

