{ pkgs
, lib
, osConfig
, ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;
  env = modules.usrEnv;
in
{
  config = mkIf (env.services.bar == "eww") {
    home.packages = with pkgs; [
      eww
    ];
    xdg.configFile."eww".source = ./source;

    modules.usrEnv.services.uiDaemon = {
      enable = true;
      package = pkgs.eww;
      command = "eww open bar";
      isDaemon = false;
    };
  };
}
