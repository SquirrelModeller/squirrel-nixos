{
  config,
  pkgs,
  lib,
  osConfig,
  quickshell,
  ...
}: let
  inherit (lib) mkIf;
  inherit (osConfig) modules;
  env = modules.usrEnv;

  systeminfo = pkgs.callPackage ./systeminfo.nix {};
in {
  config = mkIf (env.services.bar == "quickshell") {
    home.packages = with pkgs; [
      quickshell.packages.${system}.default
      systeminfo
    ];

    xdg.configFile."quickshell".source = ./src;

    modules.usrEnv.services.uiDaemon = {
      enable = true;
      package = quickshell.packages.x86_64-linux.default;
      command = "quickshell -d";
      isDaemon = false;
    };
  };
}
