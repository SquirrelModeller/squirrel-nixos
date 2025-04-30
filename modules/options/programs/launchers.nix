{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.modules.usrEnv.programs.launchers = {
    tofi.enable = mkEnableOption "tofi application launcher";
  };
}
