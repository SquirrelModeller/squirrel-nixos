{
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/3e9408d1-6c53-4c38-8390-97ff30f66777";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/E7E0-EA2D";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
}
