{ lib, ... }:
let
  inherit (lib.options) mkOption;
in
{
  options.modules.style = {
    colorScheme = {
      colors = mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          base00 = "#f9f3e0";
          baseA0 = "#D35151";
          base01 = "#D35151";
          base09 = "#fb4934";
          base02 = "#FCCD94";
          base0A = "#D9843F";
          base03 = "#FFC66D";
          base0B = "#fabd2d";
          base04 = "#E2D3AB";
          base0C = "#d1c0ab";
          base05 = "#b16286";
          base0D = "#d3869b";
          base06 = "#FFCF95";
          base0E = "#8ec07c"; ##eab964
          base07 = "#ada498";
          base0F = "#928374";
        };
      };
    };
  };
}
