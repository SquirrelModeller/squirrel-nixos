{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.modules.usrEnv.programs.apps = {
    vscodium.enable = mkEnableOption "VSCode";
    kitty.enable = mkEnableOption "Kitty Terminal Emulator";
    firefox.enable = mkEnableOption "Firefox Browser";
    emacs.enable = mkEnableOption "Emacs";
    blender.enable = mkEnableOption "Blender";
  };
  options.modules.usrEnv.programs.tools = {
    direnv.enable = mkEnableOption "direnv";
  };
}
