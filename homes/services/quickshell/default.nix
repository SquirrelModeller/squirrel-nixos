{
  config,
  pkgs,
  lib,
  osConfig,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (osConfig) modules;
  env = modules.usrEnv;

  systeminfo = pkgs.callPackage ./systeminfo.nix {};
in {
  config = mkIf (env.services.bar == "quickshell") {
    home.packages = with pkgs; [
      inputs.quickshell.packages.${pkgs.system}.default
      systeminfo
    ];

    xdg.configFile."quickshell".source = ./src;

    modules.usrEnv.services.uiDaemon = {
      enable = true;
      package = inputs.quickshell.packages.${pkgs.system}.default;
      command = "quickshell -d";
      isDaemon = false;
    };
  };
}
