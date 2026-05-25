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
      device = "/dev/dri/renderD128";
    };
  };

  users.users.jellyfin.extraGroups = ["media" "render" "video"];
  systemd = {
    services.jellyfin.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [dataDir cacheDir];
      BindReadOnlyPaths = ["/talos/media"];
    };

    tmpfiles.rules = [
      "d ${dataDir}  0750 jellyfin jellyfin - -"
      "d ${cacheDir} 0750 jellyfin jellyfin - -"
    ];
  };

  networking.firewall = {
    interfaces."enp3s0".allowedTCPPorts = [8096];
    interfaces.wg0.allowedTCPPorts = [8096];
  };
}
