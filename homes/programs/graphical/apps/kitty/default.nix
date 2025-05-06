{ config
, lib
, pkgs
, osConfig
, ...
}:
let
  inherit (lib) mkIf getExe;
  inherit (osConfig) modules;

  env = modules.usrEnv;
in
{
  config = mkIf env.programs.apps.kitty.enable {
    home.packages = with pkgs; [
      kitty
    ];
    programs.kitty = {
      enable = true;
      settings = {
        background_opacity = "0.85";
        enable_audio_bell = false;
        background = "#282828";
        font_family = "Jetbrains Mono";
        confirm_os_window_close = 0;
        color1 = "#D35151";
        color2 = "#FF9D64";
        color3 = "#FFC66D";
        color4 = "#E3E3AC";
        color5 = "#b16286";
        color6 = "#FFCF95";
        color7 = "#ada498";
        color9 = "#fb4934";
        color10 = "#D9843F";
        color11 = "#fabd2d";
        color12 = "#FFFFBB";
        color13 = "#d3869b";
        color14 = "#8ec07c";
        color15 = "#928374";
      };
    };
  };
}
