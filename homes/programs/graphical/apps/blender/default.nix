{ lib, osConfig, pkgs, ... }:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;

  env = modules.usrEnv;

in
{
  config = mkIf env.programs.apps.blender.enable {
    home.packages = [
      pkgs.blender-hip
    ];

  };
}
