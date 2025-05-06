{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.modules.system.virtualisation = {
    enable = mkEnableOption "Enable virtualisation";
    qemu.enable = mkEnableOption "Enable qemu for virtualisation";
  };
}
