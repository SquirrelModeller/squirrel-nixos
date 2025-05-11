{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.modules.system.programs.gaming.steam.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (pkgs.lib.getName pkg) [ "steam" "steam-unwrapped" ];

    programs.steam.enable = true;
  };
}
