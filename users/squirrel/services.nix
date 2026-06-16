{
  config,
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
in
  lib.mkIf config.squirrelOS.host.capabilities.graphical {
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

        services.matugen-apply = {
          description = "Apply last wallpaper theme with matugen";
          wantedBy = ["graphical-session.target"];
          after = ["graphical-session.target"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = toString (pkgs.writeShellScript "matugen-apply" ''
              STATE="$HOME/.cache/zesis/state.json"
              if [ ! -f "$STATE" ]; then exit 0; fi
              WALL=$(${pkgs.jq}/bin/jq -r '.lastWallpaper // ""' "$STATE" 2>/dev/null)
              SCHEME=$(${pkgs.jq}/bin/jq -r '.schemeType // "scheme-tonal-spot"' "$STATE" 2>/dev/null)
              if [ -n "$WALL" ] && [ -f "$WALL" ]; then
                exec ${pkgs.matugen}/bin/matugen image "$WALL" --source-color-index 0 --type "$SCHEME"
              fi
            '');
          };
        };
      };
    };
  }
