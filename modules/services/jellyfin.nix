let
  dataDir = "/talos/services/jellyfin";
  cacheDir = "/talos/services/jellyfin/cache";
  mediaDir = "/talos/media";
in
{
  services.jellyfin = {
    enable = true;
    openFirewall = false;
    dataDir = dataDir;
    cacheDir = cacheDir;
  };

  users.users.jellyfin.extraGroups = [ "media" ];

  systemd.tmpfiles.rules = [
    "d ${dataDir}  0750 jellyfin jellyfin - -"
    "d ${cacheDir} 0750 jellyfin jellyfin - -"
  ];

  systemd.services.jellyfin.serviceConfig = {
    TemporaryFileSystem = "/:ro";

    BindReadOnlyPaths = [
      "/nix/store"
      "/etc/resolv.conf"
      "/etc/hosts"
      "/etc/nsswitch.conf"
      "/etc/ssl"
      mediaDir
    ];

    PrivateTmp = true;
    ProtectHome = true;

    DevicePolicy = "closed";
    DeviceAllow = [ "/dev/dri/renderD128 rwm" ];
    BindPaths = [ "/dev/dri" dataDir cacheDir ];
  };
}
