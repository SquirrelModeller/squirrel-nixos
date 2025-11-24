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

  fileSystems."/vmdata" = {
    device = "/dev/disk/by-uuid/4f5204eb-b7ab-4870-8eec-9dbf34f2dda4";
    fsType = "btrfs";
    options = [
      "subvol=vmstore"
      "compress=zstd"
      "noatime"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /vmdata 0755 squirrel users -"
  ];


}
