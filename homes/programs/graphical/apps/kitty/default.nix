{ lib
, pkgs
, osConfig
, ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;
  inherit (modules.style.colorScheme) colors;

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
        color0 = colors.base00;
        color8 = colors.baseA0;
        color1 = colors.base01;
        color9 = colors.base09;
        color2 = colors.base02;
        color10 = colors.base0A;
        color3 = colors.base03;
        color11 = colors.base0B;
        color4 = colors.base04;
        color12 = colors.base0C;
        color5 = colors.base05;
        color13 = colors.base0D;
        color6 = colors.base06;
        color14 = colors.base0E;
        color7 = colors.base07;
        color15 = colors.base0F;
      };
    };
  };
}
