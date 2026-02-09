{
  fileSystems = {
    "/" = {
      device = "rpool/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "rpool/nix";
      fsType = "zfs";
    };

    "/home" = {
      device = "rpool/home";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/C164-3392";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [];
}
