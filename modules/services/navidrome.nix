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
      "/run/dbus"
    ];
    ProtectHostname = true;
    ProtectClock = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    KeyringMode = "private";
    RemoveIPC = true;
    UMask = lib.mkForce "0077";
    AmbientCapabilities = lib.mkForce [""];
    CapabilityBoundingSet = lib.mkForce [""];
    RestrictAddressFamilies = lib.mkForce ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
    SystemCallFilter = ["@system-service" "~@privileged"];
    # Inbound from iris (music.talosvault.net) and LAN clients. Outbound internet stays
    # open for optional metadata providers; other private ranges are denied.
    IPAddressDeny = ["10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"];
    IPAddressAllow = [
      "localhost"
      "10.0.0.1"
      "192.168.0.0/24"
    ];
  };

  networking.firewall = {
    interfaces."lan0".allowedTCPPorts = [4533];
    interfaces.wg0.allowedTCPPorts = [4533];
  };
}
