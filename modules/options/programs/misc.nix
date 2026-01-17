{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.modules.usrEnv.programs.apps = {
    firefox.enable = mkEnableOption "Firefox Browser";
  };
}
