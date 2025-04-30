{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.modules.usrEnv.programs.apps = {
    vscodium.enable = mkEnableOption "VSCode";
    kitty.enable = mkEnableOption "Kitty Terminal Emulator";
    firefox.enable = mkEnableOption "Firefox Browser";
  };
}
