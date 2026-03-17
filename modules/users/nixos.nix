{
  config,
  lib,
  pkgs,
  inputs,
  self,
  getUserProgramsPath,
  getUserMisc,
  ...
}: let
  inherit (lib) mkIf listToAttrs map;

  userLib = import ./user-discovery.nix {inherit lib self;};
  inherit (userLib) availableUsers getUserServicesImport;

  enabledUsers = config.squirrelOS.users.enabled;

  mkCtx = config: {
    host = config.networking.hostName or "unknown";
    platform = {
      isLinux = true;
      isDarwin = false;
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
  imports =
    [./default.nix]
    ++ lib.filter (x: x != null) (map getUserServicesImport availableUsers);

  config = mkIf (enabledUsers != []) {
    users.users = listToAttrs (
      map
      (username: {
        name = username;
        value =
          {
            isNormalUser = true;
            home = "/home/${username}";
            shell = pkgs.zsh;
            extraGroups = [
              "wheel"
              "media"
              "smbusers"
              "networkmanager"
              "libvirt"
              "libvirtd"
            ];
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
