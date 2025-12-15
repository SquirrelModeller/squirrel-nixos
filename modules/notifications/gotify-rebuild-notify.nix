{ config, lib, pkgs, ... }:
let
  cfg = config.squirrelOS.notifications.gotify;

  sshNotifyScript = pkgs.writeShellScript "gotify-ssh-notify" ''
    set -euo pipefail
    
    TOKEN_FILE="${cfg.tokenFile}"
    KNOWN_IPS_FILE="${cfg.knownIPsFile}"
    
    if [ ! -f "$TOKEN_FILE" ]; then
      echo "Gotify token file not found: $TOKEN_FILE" >&2
      exit 1
    fi
    
    USER="''${PAM_USER:-unknown}"
    REMOTE_HOST="''${PAM_RHOST:-unknown}"
    
    if [ "$REMOTE_HOST" = "unknown" ] || [ -z "$REMOTE_HOST" ]; then
      exit 0
    fi
    
    # Create known IPs file if it doesn't exist
    ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$KNOWN_IPS_FILE")"
    ${pkgs.coreutils}/bin/touch "$KNOWN_IPS_FILE"
    
    # If we know the IP, we just exit
    if ${pkgs.gnugrep}/bin/grep -qxF "$REMOTE_HOST" "$KNOWN_IPS_FILE"; then
      exit 0
    fi
    echo "$REMOTE_HOST" >> "$KNOWN_IPS_FILE"
    
    TOKEN=$(${pkgs.coreutils}/bin/cat "$TOKEN_FILE")
    HOSTNAME=$(${pkgs.nettools}/bin/hostname)
    TIMESTAMP=$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')
    
    TITLE="🔐 New SSH Login from Unknown IP"
    MESSAGE="User $USER logged in to $HOSTNAME from NEW IP: $REMOTE_HOST at $TIMESTAMP"
    PRIORITY=8
    
    ${pkgs.curl}/bin/curl -s -X POST "${cfg.serverUrl}/message?token=$TOKEN" \
      -F "title=$TITLE" \
      -F "message=$MESSAGE" \
      -F "priority=$PRIORITY" \
      || echo "Failed to send SSH notification" >&2
  '';

  rebuildNotifyScript = pkgs.writeShellScript "gotify-rebuild-notify" ''
    set -euo pipefail
    
    TOKEN_FILE="${cfg.tokenFile}"
    
    if [ ! -f "$TOKEN_FILE" ]; then
      echo "Gotify token file not found: $TOKEN_FILE" >&2
      exit 1
    fi
    
    TOKEN=$(${pkgs.coreutils}/bin/cat "$TOKEN_FILE")
    HOSTNAME=$(${pkgs.nettools}/bin/hostname)
    TIMESTAMP=$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')
    
    TITLE="✅ System Rebuilt"
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
    enable = lib.mkEnableOption "Gotify notifications";

    serverUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://notify.talosvault.net";
      description = "Gotify server URL";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/gotify/app-token";
      description = "Path to file containing Gotify application token";
    };

    knownIPsFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/gotify/known-ssh-ips";
      description = "Path to file storing known SSH IP addresses";
    };

    notifyRebuild = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Send notifications on system rebuild";
    };

    notifySSH = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Send notifications on SSH logins";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.notifyRebuild {
      system.activationScripts.gotifyNotify = {
        text = ''
          ${rebuildNotifyScript} || true
        '';
        deps = [ ];
      };
    })

    (lib.mkIf cfg.notifySSH {
      security.pam.services.sshd.rules.session.gotify = {
        order = 9999;
        control = "optional";
        modulePath = "${pkgs.pam}/lib/security/pam_exec.so";
        args = [ "${sshNotifyScript}" ];
      };
    })
  ]);
}
