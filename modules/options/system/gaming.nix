{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.modules.system.programs.gaming.steam = {
    enable = mkEnableOption "Enable steam";
  };
}
