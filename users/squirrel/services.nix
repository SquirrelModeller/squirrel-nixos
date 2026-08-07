{
  config,
  lib,
  pkgs,
  ...
}: let
  onThemeChange = pkgs.writeShellScript "on-theme-change" ''
    ${pkgs.procps}/bin/pkill -SIGUSR1 kitty || true
    ${pkgs.hyprland}/bin/hyprctl reload || true
  '';
in
  lib.mkIf config.squirrelOS.host.capabilities.graphical {
    services.zesis.enable = true;

    hjem.users.squirrel = {
      files = {
        ".config/zesis/on-theme-change".source = onThemeChange;
      };

      systemd = {
        enable = true;

        services = {
          hypridle = {
            description = "Hypridle";
            wantedBy = ["default.target"];
            after = ["graphical-session.target"];

            path = [pkgs.hypridle pkgs.quickshell pkgs.procps pkgs.coreutils pkgs.util-linux pkgs.systemd];
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
