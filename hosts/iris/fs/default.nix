{modulesPath, ...}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/992e3bf1-3977-4a40-ada7-5148e6c0e0bb";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7993-2D30";
    fsType = "vfat";
  };

  swapDevices = [];
}
