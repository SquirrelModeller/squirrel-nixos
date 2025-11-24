{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.squirrelOS.notifications.gotify;

  notifyScript = pkgs.writeShellScript "gotify-rebuild-notify" ''
    set -euo pipefail
    
    TOKEN_FILE="${cfg.tokenFile}"
    
    if [ ! -f "$TOKEN_FILE" ]; then
      echo "Gotify token file not found: $TOKEN_FILE" >&2
      exit 1
    fi
    
    TOKEN=$(cat "$TOKEN_FILE")
    HOSTNAME=$(${pkgs.hostname}/bin/hostname)
    TIMESTAMP=$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')
    
    TITLE="System Rebuilt"
    MESSAGE="NixOS configuration on $HOSTNAME was rebuilt successfully at $TIMESTAMP"
    PRIORITY=5
    
    ${pkgs.curl}/bin/curl -s -X POST "${cfg.serverUrl}/message?token=$TOKEN" \
      -F "title=$TITLE" \
      -F "message=$MESSAGE" \
      -F "priority=$PRIORITY" \
      || echo "Failed to send Gotify notification" >&2
  '';
in
{
  options.squirrelOS.notifications.gotify = {
    enable = mkEnableOption "Gotify rebuild notifications";

    serverUrl = mkOption {
      type = types.str;
      default = "http://localhost:8090";
      description = "Gotify server URL";
    };

    tokenFile = mkOption {
      type = types.path;
      default = "/var/lib/gotify/app-token";
      description = "Path to file containing Gotify application token";
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts.gotifyNotify = {
      text = ''
        ${notifyScript} || true
      '';
      deps = [ ];
    };
  };
}
