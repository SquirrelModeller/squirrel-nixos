{
  pkgs,
  inputs,
  ...
}: {
  hjem.users.squirrel = {
    systemd = {
      enable = true;

      # services.quickshell = {
      #   description = "Quickshell";
      #   wantedBy = ["graphical-session.target"];
      #   after = ["graphical-session.target"];
      #   partOf = ["graphical-session.target"];

      #   serviceConfig = {
      #     ExecStart = "${qs}/bin/quickshell";
      #     Restart = "on-failure";
      #     RestartSec = 5;
      #   };
      # };

      services.hypridle = {
        description = "Hypridle";
        wantedBy = ["default.target"];
        after = ["graphical-session.target"];

        path = [pkgs.hypridle inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default pkgs.procps pkgs.coreutils pkgs.util-linux pkgs.systemd];
        serviceConfig = {
          ExecStart = "${pkgs.hypridle}/bin/hypridle";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
  };
}
