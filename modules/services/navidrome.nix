_: let
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
    };
  };

  networking.firewall = {
    interfaces."enp4s0".allowedTCPPorts = [4533];
    interfaces.wg0.allowedTCPPorts = [4533];
  };
}
