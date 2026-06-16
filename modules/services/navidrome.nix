{lib, ...}: let
  musicDir = "/talos/media/music";
  dataDir = "/var/lib/navidrome";
in {
  users = {
    groups.navidrome = {};
    groups.media = {};

    users.navidrome = {
      isSystemUser = true;
      group = "navidrome";
      extraGroups = ["media"];
    };
  };

  services.navidrome = {
    enable = true;
    openFirewall = false;
    user = "navidrome";
    group = "navidrome";

    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = musicDir;
      DataFolder = dataDir;
      BaseUrl = "";

      ScanSchedule = "@every 30m";
      LogLevel = "info";
      TranscodingCacheSize = "1GB";
      EnableCoverAnimation = true;

      EnableSharing = true;
      DefaultShareExpiration = "168h";
    };
  };

  systemd.services.navidrome.serviceConfig = {
    ProtectSystem = lib.mkForce "strict";
    ProtectHome = true;
    PrivateTmp = true;
    NoNewPrivileges = true;
    LockPersonality = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    SystemCallArchitectures = "native";
    ReadWritePaths = [dataDir];
    InaccessiblePaths = [
      "/talos/users"
      "/talos/services"
      "/talos/shared"
      "/talos/services/nextcloud"
      "/talos/services/vaultwarden"
      "/boot"
      "/root"
    ];
  };

  networking.firewall = {
    interfaces."enp3s0".allowedTCPPorts = [4533];
    interfaces.wg0.allowedTCPPorts = [4533];
  };
}
