{ lib
, osConfig
, inputs
, ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;

  env = modules.usrEnv;
in
{
  #imports = [ inputs.catppuccin.homeModules.catppuccin ];
  config = mkIf env.style.gtk.enable {
    # gtk = {
    #   enable = true;
    #   catppuccin = {
    #     enable = true;
    #     flavor = "mocha";
    #     accent = "peach";
    #     size = "standard";
    #     tweaks = [ "normal" ];
    #   };
    # };

    dconf.settings = {
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "''";
      };
    };
  };
}
