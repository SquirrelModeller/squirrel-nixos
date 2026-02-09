{
  lib,
  pkgs,
  ...
}: {
  config = {
    boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.kernelParams = ["amd_pstate=active"];

    hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  };
}
