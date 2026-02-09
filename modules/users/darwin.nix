{
  config,
  lib,
  pkgs,
  inputs,
  getUserProgramsPath,
  getUserMisc,
  ...
}: let
  inherit (lib) mkIf listToAttrs map;
  enabledUsers = config.squirrelOS.users.enabled;

  mkCtx = config: {
    host = config.networking.hostName or "unknown";
    platform = {
      isLinux = false;
      isDarwin = true;
    };
    roles = config.squirrelOS.host.roles or [];
    tags = config.squirrelOS.host.tags or [];
    capabilities =
      config.squirrelOS.host.capabilities or {
        graphical = false;
        wayland = false;
        battery = false;
      };
    userFeatures = config.squirrelOS.userFeatures or {};
    colors = config.modules.style.colorScheme.colors or {};
  };

  ctx = mkCtx config;
in {
  imports = [./default.nix];

  config = mkIf (enabledUsers != []) {
    users.users = listToAttrs (
      map
      (username: {
        name = username;
        value =
          {
            home = "/Users/${username}";
            shell = pkgs.zsh;
            packages = import (getUserProgramsPath username) {
              inherit
                pkgs
                lib
                inputs
                ctx
                ;
            };
          }
          // (getUserMisc username);
      })
      enabledUsers
    );
  };
}
