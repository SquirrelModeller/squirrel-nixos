{ lib, ... }:
let
  musicDir = "/talos/media/music";
  dataDir = "/var/lib/navidrome";
in
{

  users.groups.navidrome = { };
  users.groups.media = lib.mkDefault { };

  users.users.navidrome = {
    isSystemUser = true;
    group = "navidrome";
    extraGroups = [ "media" ];
  };

  services.navidrome = {
    enable = true;

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
    };
  };
}
