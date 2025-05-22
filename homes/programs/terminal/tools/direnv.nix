{ lib, osConfig, ... }:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;
  env = modules.usrEnv;
in
{


  config = mkIf env.programs.tools.direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    xdg.configFile."direnv/direnvrc".text = ''
      use flake() {
        nix_direnv_load
      }
    '';
  };
}
