{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.modules.usrEnv.style = {
    gtk.enable = mkEnableOption "Enable GTK styling";
  };
}
