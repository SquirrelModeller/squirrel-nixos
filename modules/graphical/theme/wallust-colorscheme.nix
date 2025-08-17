{ config, lib, pkgs, ... }:
let
  inherit (lib) mkMerge;

  c = config.modules.style.colorScheme.colors;

  toPywal = c: {
    special = {
      background = c.background or c.base00;
      foreground = c.base00;
      cursor = c.base00;
    };
    colors = {
      color0 = c.base00;
      color1 = c.base01;
      color2 = c.base02;
      color3 = c.base03;
      color4 = c.base04;
      color5 = c.base05;
      color6 = c.base06;
      color7 = c.base07;
      color8 = c.base08;
      color9 = c.base09;
      color10 = c.base0A;
      color11 = c.base0B;
      color12 = c.base0C;
      color13 = c.base0D;
      color14 = c.base0E;
      color15 = c.base0F;
    };
  };

  schemeName = "default";
  schemeJSON = builtins.toJSON (toPywal c);

  users = config.squirrelOS.users.enabled;
in
{
  config = {
    hjem.users = mkMerge (map
      (u: {
        ${u}.files = {
          ".config/wallust/colorschemes/${schemeName}.json".text = schemeJSON;
        };
      })
      users);
    systemd.user.services.wallust-apply = {
      enable = true;
      wantedBy = [ "default.target" ];
      description = "Generates default theme with wallust to cache";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.wallust}/bin/wallust cs ${schemeName}";
      };
    };
  };
}
