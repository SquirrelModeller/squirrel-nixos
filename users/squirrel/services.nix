{
  lib,
  pkgs,
  inputs,
  ...
}: let
  findFiles = import ../../lib/findFiles.nix {inherit lib;};
  qs = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  athroisma = inputs.squirrel-quickshell.packages.${pkgs.stdenv.hostPlatform.system}.athroisma;
  qsConfigFiles = lib.mapAttrs' (name: value:
    lib.nameValuePair ".config/quickshell/${name}" value)
  (findFiles inputs.squirrel-quickshell);
in {
  hjem.users.squirrel = {
    files = qsConfigFiles;

    systemd = {
      enable = true;

      services.quickshell = {
        description = "Quickshell";
        wantedBy = ["graphical-session.target"];
        after = ["graphical-session.target"];
        partOf = ["graphical-session.target"];
        path = [athroisma];
        serviceConfig = {
          ExecStart = "${qs}/bin/quickshell";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

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
