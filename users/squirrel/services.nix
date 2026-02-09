{pkgs, ...}: {
  hjem.users.squirrel = {
    systemd = {
      enable = true;

      services.hyprpaper = {
        description = "Hyprpaper";
        wantedBy = ["default.target"];
        after = ["graphical-session.target"];

        path = [pkgs.hyprpaper];
        serviceConfig = {
          ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      services.hypridle = {
        description = "Hypridle";
        wantedBy = ["default.target"];
        after = ["graphical-session.target"];

        path = [pkgs.hypridle pkgs.hyprlock pkgs.procps pkgs.coreutils pkgs.util-linux pkgs.systemd];
        serviceConfig = {
          ExecStart = "${pkgs.hypridle}/bin/hypridle";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
  };
}
