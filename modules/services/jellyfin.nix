{pkgs, ...}: let
  dataDir = "/talos/services/jellyfin";
  cacheDir = "/talos/services/jellyfin/cache";
in {
  services.jellyfin = {
    enable = true;
    openFirewall = false;
    inherit dataDir;
    inherit cacheDir;
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  users.users.jellyfin.extraGroups = ["media" "render" "video"];
  systemd = {
    services.jellyfin.serviceConfig = {
      DeviceAllow = [
        "/dev/dri/renderD128 rw"
        "/dev/nvidia0 rw"
        "/dev/nvidiactl rw"
        "/dev/nvidia-modeset rw"
        "/dev/nvidia-uvm rw"
        "/dev/nvidia-uvm-tools rw"
      ];
      PrivateDevices = false;
    };

    services.jellyfin.environment = {
      LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
    };

    tmpfiles.rules = [
      "d ${dataDir}  0750 jellyfin jellyfin - -"
      "d ${cacheDir} 0750 jellyfin jellyfin - -"
    ];
  };

  networking.firewall = {
    interfaces."enp4s0".allowedTCPPorts = [8096];
    interfaces.wg0.allowedTCPPorts = [8096];
  };
}
