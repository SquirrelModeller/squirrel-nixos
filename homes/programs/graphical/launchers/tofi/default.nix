{ lib
, pkgs
, osConfig
, ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;

  env = modules.usrEnv;
in
{
  config = mkIf env.programs.launchers.tofi.enable {
    home.packages = with pkgs; [
      tofi
    ];
    xdg.configFile."tofi/config".text = ''
      width = 100%
      height = 100%
      border-width = 0
      outline-width = 0
      padding-left = 35%
      padding-top = 35%
      result-spacing = 25
      num-results = 5
      font = monospace
      selection-color = #FFB97C
      background-color = #000A
    '';
  };
}
