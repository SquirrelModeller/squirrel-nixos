{ config, lib, pkgs, ... }:

let
  gotifyCfg = config.squirrelOS.notifications.gotify;
  zfsCfg = config.squirrelOS.notifications.zfs;

  zfsHealthCheckScript = pkgs.writeShellScript "zfs-health-check" ''
    set -euo pipefail

    SEND_OK=${if zfsCfg.sendOkNotification then "1" else "0"}

    TOKEN_FILE="${gotifyCfg.tokenFile}"

    if [ ! -f "$TOKEN_FILE" ]; then
      echo "Gotify token file not found: $TOKEN_FILE" >&2
      exit 1
    fi

    TOKEN=$(cat "$TOKEN_FILE")
    HOSTNAME=$(${pkgs.nettools}/bin/hostname)

    send_notification() {
      local title="$1"
      local message="$2"
      local priority="$3"

      ${pkgs.curl}/bin/curl -s -X POST "${gotifyCfg.serverUrl}/message?token=$TOKEN" \
        -F "title=$title" \
        -F "message=$message" \
        -F "priority=$priority" \
        || echo "Failed to send Gotify notification" >&2
    }

    POOLS=$(${pkgs.zfs}/bin/zpool list -H -o name)
    any_issues=0

    for POOL in $POOLS; do
      HEALTH=$(${pkgs.zfs}/bin/zpool list -H -o health "$POOL")

      case "$HEALTH" in
        ONLINE)
          # Pool is healthy, but check for degraded devices
          DEGRADED=$(${pkgs.zfs}/bin/zpool status "$POOL" | grep -c "DEGRADED" || true)
          if [ "$DEGRADED" -gt 0 ]; then
            STATUS=$(${pkgs.zfs}/bin/zpool status "$POOL")
            any_issues=1
            send_notification \
              "⚠️ ZFS Pool Degraded" \
              "Pool '$POOL' on $HOSTNAME has degraded devices:\n\n$STATUS" \
              8
          fi
          ;;
      
        DEGRADED)
          STATUS=$(${pkgs.zfs}/bin/zpool status "$POOL")
          any_issues=1
          send_notification \
            "⚠️ ZFS Pool Degraded" \
            "Pool '$POOL' on $HOSTNAME is in DEGRADED state:\n\n$STATUS" \
            8
          ;;
      
        FAULTED)
          STATUS=$(${pkgs.zfs}/bin/zpool status "$POOL")
          any_issues=1
          send_notification \
            "🔴 ZFS Pool Faulted" \
            "CRITICAL: Pool '$POOL' on $HOSTNAME is FAULTED:\n\n$STATUS" \
            10
          ;;
      
        UNAVAIL)
          STATUS=$(${pkgs.zfs}/bin/zpool status "$POOL")
          any_issues=1
          send_notification \
            "🔴 ZFS Pool Unavailable" \
            "CRITICAL: Pool '$POOL' on $HOSTNAME is UNAVAILABLE:\n\n$STATUS" \
            10
          ;;
      
        *)
          STATUS=$(${pkgs.zfs}/bin/zpool status "$POOL")
          any_issues=1
          send_notification \
            "⚠️ ZFS Pool Unknown State" \
            "Pool '$POOL' on $HOSTNAME has unknown health status '$HEALTH':\n\n$STATUS" \
            8
          ;;
      esac

      CKSUM_ERRORS=$(${pkgs.zfs}/bin/zpool status "$POOL" \
        | ${pkgs.gawk}/bin/awk '/cksum/{sum+=$5} END{print sum+0}')

      if [ "$CKSUM_ERRORS" -gt 0 ]; then
        any_issues=1
        send_notification \
          "⚠️ ZFS Checksum Errors" \
          "Pool '$POOL' on $HOSTNAME has $CKSUM_ERRORS checksum errors. This may indicate failing hardware." \
          8
      fi
    done

    if [ "$any_issues" -eq 0 ] && [ "$SEND_OK" -eq 1 ]; then
      send_notification \
        "✅ ZFS Pools Healthy" \
        "All ZFS pools on $HOSTNAME are healthy. No issues detected during this check." \
        3
    fi
  '';

  zedScrubStartScript = pkgs.writeShellScript "scrub_start.sh" ''
    #!/bin/sh
    # shellcheck disable=SC2154
    # scrub_start.sh - Notify via Gotify when scrub starts

    [ -f "''${ZED_ZEDLET_DIR}/zed.rc" ] && . "''${ZED_ZEDLET_DIR}/zed.rc"
    . "''${ZED_ZEDLET_DIR}/zed-functions.sh"

    [ -n "''${ZEVENT_POOL}" ] || exit 1
    [ -n "''${ZEVENT_SUBCLASS}" ] || exit 1
    
    TOKEN_FILE="${gotifyCfg.tokenFile}"
    
    if [ ! -f "$TOKEN_FILE" ]; then
      exit 0
    fi
    
    TOKEN=$(cat "$TOKEN_FILE")
    HOSTNAME=$(${pkgs.nettools}/bin/hostname)
    TIMESTAMP=$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')
    
    zed_log_msg "Sending Gotify notification for scrub start on ''${ZEVENT_POOL}"
    
    ${pkgs.curl}/bin/curl -s -X POST "${gotifyCfg.serverUrl}/message?token=$TOKEN" \
      -F "title=🔍 ZFS Scrub Started" \
      -F "message=ZFS scrub started on pool ''${ZEVENT_POOL} on $HOSTNAME at $TIMESTAMP" \
      -F "priority=5" \
      || exit 0
  '';

  zedScrubFinishScript = pkgs.writeShellScript "scrub_finish.sh" ''
    #!/bin/sh
    # shellcheck disable=SC2154
    # Notify via Gotify when scrub finishes

    [ -f "''${ZED_ZEDLET_DIR}/zed.rc" ] && . "''${ZED_ZEDLET_DIR}/zed.rc"
    . "''${ZED_ZEDLET_DIR}/zed-functions.sh"

    [ -n "''${ZEVENT_POOL}" ] || exit 1
    [ -n "''${ZEVENT_SUBCLASS}" ] || exit 1
    zed_check_cmd "''${ZPOOL}" || exit 1

    TOKEN_FILE="${gotifyCfg.tokenFile}"

    if [ ! -f "$TOKEN_FILE" ]; then
      exit 0
    fi

    TOKEN=$(cat "$TOKEN_FILE")
    HOSTNAME=$(${pkgs.nettools}/bin/hostname)

    STATUS=$(''${ZPOOL} status "''${ZEVENT_POOL}" \
      | ${pkgs.gnugrep}/bin/grep -A 5 "scan:")

    if echo "$STATUS" | ${pkgs.gnugrep}/bin/grep -q "with 0 errors"; then
      PRIORITY=5
      TITLE="✅ ZFS Scrub Complete"
    else
      PRIORITY=9
      TITLE="⚠️ ZFS Scrub Complete - Errors Found"
    fi

    zed_log_msg "Sending Gotify notification for scrub finish on ''${ZEVENT_POOL}"

    ${pkgs.curl}/bin/curl -s -X POST "${gotifyCfg.serverUrl}/message?token=$TOKEN" \
      -F "title=$TITLE" \
      -F "message=Pool ''${ZEVENT_POOL} on $HOSTNAME scrub completed:\n\n$STATUS" \
      -F "priority=$PRIORITY" \
      || exit 0
  '';

  zedResilveredScript = pkgs.writeShellScript "resilver_finish.sh" ''
    #!/bin/sh
    # shellcheck disable=SC2154
    # Notify via Gotify when resilver finishes

    [ -f "''${ZED_ZEDLET_DIR}/zed.rc" ] && . "''${ZED_ZEDLET_DIR}/zed.rc"
    . "''${ZED_ZEDLET_DIR}/zed-functions.sh"

    [ -n "''${ZEVENT_POOL}" ] || exit 1
    [ -n "''${ZEVENT_SUBCLASS}" ] || exit 1
    zed_check_cmd "''${ZPOOL}" || exit 1

    TOKEN_FILE="${gotifyCfg.tokenFile}"

    if [ ! -f "$TOKEN_FILE" ]; then
      exit 0
    fi

    TOKEN=$(cat "$TOKEN_FILE")
    HOSTNAME=$(${pkgs.nettools}/bin/hostname)

    STATUS=$(''${ZPOOL} status "''${ZEVENT_POOL}")

    zed_log_msg "Sending Gotify notification for resilver finish on ''${ZEVENT_POOL}"

    ${pkgs.curl}/bin/curl -s -X POST "${gotifyCfg.serverUrl}/message?token=$TOKEN" \
      -F "title=🔧 ZFS Resilver Complete" \
      -F "message=Pool ''${ZEVENT_POOL} on $HOSTNAME resilver completed:\n\n$STATUS" \
      -F "priority=7" \
      || exit 0
  '';

in
{
  options.squirrelOS.notifications.zfs = {
    enableHealthCheck = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable periodic ZFS health checks with Gotify notifications";
    };

    healthCheckInterval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "How often to check ZFS health (systemd timer format)";
    };

    enableScrubNotifications = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable notifications when ZFS scrubs complete";
    };

    sendOkNotification = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If true, send a Gotify notification when all ZFS pools are healthy and no issues are detected";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (gotifyCfg.enable && zfsCfg.enableHealthCheck) {
      systemd.services.zfs-health-check = {
        description = "Check ZFS pool health and notify via Gotify";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = zfsHealthCheckScript;
        };
      };

      systemd.timers.zfs-health-check = {
        description = "Timer for ZFS health checks";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = zfsCfg.healthCheckInterval;
          Persistent = true;
        };
      };
    })

    (lib.mkIf (gotifyCfg.enable && zfsCfg.enableScrubNotifications) {
      services.zfs.zed.settings = {
        ZED_DEBUG_LOG = "/var/log/zed.debug.log";
        ZED_EMAIL_ADDR = [ "root" ];
        ZED_EMAIL_PROG = "${pkgs.mailutils}/bin/mail";
        ZED_EMAIL_OPTS = "@ADDRESS@";

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = false;

        ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = false;
      };

      environment.etc = {
        "zfs/zed.d/scrub.start.sh" = {
          source = zedScrubStartScript;
          mode = "0755";
        };
        "zfs/zed.d/scrub.finish.sh" = {
          source = zedScrubFinishScript;
          mode = "0755";
        };
        "zfs/zed.d/resilver.finish.sh" = {
          source = zedResilveredScript;
          mode = "0755";
        };
        "zfs/zed.d/scrub_start.sh" = {
          source = zedScrubStartScript;
          mode = "0755";
        };
        "zfs/zed.d/scrub_finish.sh" = {
          source = zedScrubFinishScript;
          mode = "0755";
        };
        "zfs/zed.d/resilver_finish.sh" = {
          source = zedResilveredScript;
          mode = "0755";
        };
      };

      systemd.services.zfs-zed.restartTriggers = [
        zedScrubStartScript
        zedScrubFinishScript
        zedResilveredScript
      ];
    })
  ];
}
