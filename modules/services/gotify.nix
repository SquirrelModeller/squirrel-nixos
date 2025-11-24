{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.gotify;
in
{
  options.services.gotify = {
    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/gotify";
      description = "Directory to store Gotify data";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gotify = {
      description = "Gotify notification server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        User = "gotify";
        Group = "gotify";
        StateDirectory = "gotify";
        WorkingDirectory = cfg.stateDir;
        ExecStart = "${pkgs.gotify-server}/bin/server"; # Changed from gotify-server to server
        Restart = "on-failure";
        RestartSec = "10s";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.stateDir ];
      };
      environment = {
        GOTIFY_SERVER_PORT = toString cfg.port;
        GOTIFY_DATABASE_DIALECT = "sqlite3";
        GOTIFY_DATABASE_CONNECTION = "${cfg.stateDir}/gotify.db";
      };
    };

    users.users.gotify = {
      isSystemUser = true;
      group = "gotify";
      home = cfg.stateDir;
    };

    users.groups.gotify = { };

    networking.firewall.interfaces."enp3s0".allowedTCPPorts = mkIf cfg.enable [ cfg.port ];
    networking.firewall.interfaces.wg0.allowedTCPPorts = mkIf cfg.enable [ cfg.port ];
  };
}
