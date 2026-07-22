{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  findFiles = import ../../lib/findFiles.nix {inherit lib;};
  qs = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default.withModules [pkgs.qt6.qtquick3d];
  athroisma = inputs.zesis.packages.${pkgs.stdenv.hostPlatform.system}.athroisma;
  qsConfigFiles = lib.mapAttrs' (name: value:
    lib.nameValuePair ".config/quickshell/${name}" value)
  (findFiles inputs.zesis);

  onThemeChange = pkgs.writeShellScript "on-theme-change" ''
    ${pkgs.procps}/bin/pkill -SIGUSR1 kitty || true
    ${pkgs.hyprland}/bin/hyprctl reload || true
  '';
in
  lib.mkIf config.squirrelOS.host.capabilities.graphical {
    hjem.users.squirrel = {
      files = qsConfigFiles // {
        ".config/zesis/on-theme-change".source = onThemeChange;
      };

      systemd = {
        enable = true;

        services = {
          quickshell = {
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

          hypridle = {
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

          matugen-apply = {
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
                MODE=$(${pkgs.jq}/bin/jq -r '.palette // "dark"' "$STATE" 2>/dev/null)
                if [ -n "$WALL" ] && [ -f "$WALL" ]; then
                  exec ${pkgs.matugen}/bin/matugen image "$WALL" --source-color-index 0 --type "$SCHEME" --mode "$MODE"
                fi
              '');
            };
          };
        };
      };
    };
  }
