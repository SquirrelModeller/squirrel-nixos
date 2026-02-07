{ config
, lib
, pkgs
, inputs
, self
, availableUsers
, getUserProgramsPath
, getUserMisc
, ...
}:
let
  inherit (lib) mkIf listToAttrs map;
  enabledUsers = config.squirrelOS.users.enabled;

  mkCtx = config: {
    host = config.networking.hostName or "unknown";
    platform = {
      isLinux = true;
      isDarwin = false;
    };
    roles = config.squirrelOS.host.roles or [ ];
    tags = config.squirrelOS.host.tags or [ ];
    capabilities =
      config.squirrelOS.host.capabilities or {
        graphical = false;
        wayland = false;
        battery = false;
      };
    userFeatures = config.squirrelOS.userFeatures or { };
    colors = config.modules.style.colorScheme.colors or { };
  };

  ctx = mkCtx config;
in
{
  imports =
    let
      getUserServicesImport =
        username:
        let
          f = "${self}/users/${username}/services.nix";
        in
        if builtins.pathExists f then f else null;
      serviceImports = map getUserServicesImport availableUsers;
    in
    [ ./default.nix ] ++ (lib.filter (x: x != null) serviceImports);

  config = mkIf (enabledUsers != [ ]) {
    users.users = listToAttrs (
      map
        (username: {
          name = username;
          value = {
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
