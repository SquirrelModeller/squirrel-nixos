let
  dataDir = "/talos/services/vaultwarden";
in {
  services.vaultwarden = {
    enable = true;

    config = {
      DATABASE_URL = "${dataDir}/db.sqlite3";
      DATA_FOLDER = dataDir;

      DOMAIN = "https://vault.talosvault.net";
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = true;

      PASSWORD_HINTS_ALLOWED = false;
      SHOW_PASSWORD_HINT = false;

      ENABLE_WEBSOCKET = true;
      WEBSOCKET_ADDRESS = "0.0.0.0";
      WEBSOCKET_PORT = 3012;

      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8000;

      ROCKET_LOG = "critical";
    };
  };

  systemd = {
    services.vaultwarden.serviceConfig = {
      ReadWritePaths = ["/talos/services/vaultwarden"];
    };

    services.vaultwarden.after = ["zfs-mount.service"];

    tmpfiles.rules = [
      "d ${dataDir}      0750 vaultwarden vaultwarden - -"
      "d ${dataDir}/icon 0750 vaultwarden vaultwarden - -"
    ];
  };

  networking.firewall = {
    interfaces."enp4s0".allowedTCPPorts = [8000 3012];
    interfaces.wg0.allowedTCPPorts = [8000 3012];
  };
}
