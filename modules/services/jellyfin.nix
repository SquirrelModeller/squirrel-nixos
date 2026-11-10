{lib, ...}: let
  dataDir = "/talos/services/jellyfin";
  cacheDir = "/talos/services/jellyfin/cache";
in {
  services.jellyfin = {
    enable = true;
    openFirewall = false;
    inherit dataDir;
    inherit cacheDir;
    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };
  };

  users.users.jellyfin.extraGroups = ["media" "render" "video"];
  systemd = {
    services.jellyfin.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      LockPersonality = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      SystemCallArchitectures = "native";
      ReadWritePaths = [dataDir cacheDir];
      BindReadOnlyPaths = ["/talos/media"];
      InaccessiblePaths = [
        "/talos/users"
        "/talos/services/nextcloud"
        "/talos/services/vaultwarden"
        "/talos/shared"
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
      # Inbound from iris (watch.talosvault.net) and LAN clients. Outbound internet stays
      # open for metadata/image providers; other private ranges (wg0 peers, rest of LAN) are denied.
      IPAddressDeny = ["10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"];
      IPAddressAllow = [
        "localhost"
        "10.0.0.1"
        "192.168.0.0/24"
      ];
    };

    tmpfiles.rules = [
      "d ${dataDir}  0750 jellyfin jellyfin - -"
      "d ${cacheDir} 0750 jellyfin jellyfin - -"
    ];
  };

  networking.firewall = {
    interfaces."lan0".allowedTCPPorts = [8096];
    interfaces.wg0.allowedTCPPorts = [8096];
  };
}
