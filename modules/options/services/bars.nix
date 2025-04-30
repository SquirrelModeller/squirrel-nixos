{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.modules.usrEnv.services = {
    eww.enable = mkEnableOption "Eww";

    bar = mkOption {
      type = types.enum ["eww" "quickshell" "none"];
      default = "none";
      description = "Bar provider to use";
    };
  };
}
