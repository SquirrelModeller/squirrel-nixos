{ config
, lib
, pkgs
, inputs
, self
, availableUsers
, hostName ? null
, hostSystem ? pkgs.system
, ...
}:

let
  inherit (lib) mkIf mkMerge listToAttrs map;

  findFiles = import ../lib/findFiles.nix { inherit lib; };

  ctx = {
    host = if hostName != null then hostName else (config.networking.hostName or "unknown");
    system = hostSystem;

    platform = {
      isLinux = pkgs.stdenv.isLinux;
      isDarwin = pkgs.stdenv.isDarwin;
    };

    roles = config.squirrelOS.host.roles or [ ];
    tags = config.squirrelOS.host.tags  or [ ];
    capabilities = config.squirrelOS.host.capabilities or {
      graphical = false;
      wayland = false;
      battery = false;
    };

    userFeatures = config.squirrelOS.userFeatures or { };
    colors = (config.modules.style.colorScheme.colors or { });
  };

  getUserDotfiles = username:
    let dotfilesDir = ../users + "/${username}/dotfiles";
    in if builtins.pathExists dotfilesDir then findFiles dotfilesDir else { };

  getUserServices = username:
    let f = "${self}/users/${username}/services.nix";
    in if builtins.pathExists f then import f { inherit pkgs lib inputs username ctx; } else { };

  getUserMisc = username:
    let f = "${self}/users/${username}/misc.nix";
    in if builtins.pathExists f then import f { } else { };

  getUserPrograms = username:
    let f = "${self}/users/${username}/programs/default.nix";
    in import f { inherit pkgs lib inputs ctx; };

in
{
  options = {
    squirrelOS.users.enabled = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = availableUsers;
      description = "List of user profiles to enable on this host";
      example = [ "squirrel" "guest" ];
    };
    squirrelOS.users.available = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      default = availableUsers;
      description = "All available user profiles (auto-discovered)";
    };
  };

  config =
    let
      enabledUsers = config.squirrelOS.users.enabled;
      invalidUsers = lib.filter (u: !(lib.elem u availableUsers)) enabledUsers;
    in
    mkMerge [
      (mkIf (enabledUsers != [ ]) {
        assertions = [{
          assertion = lib.length invalidUsers == 0;
          message =
            "Unknown user profiles: ${lib.toString invalidUsers}. "
            + "Available: ${lib.toString availableUsers}";
        }];

        users.users = listToAttrs (map
          (username: {
            name = username;
            value = {
              isNormalUser = true;
              home = "/home/${username}";
              shell = pkgs.zsh;
              extraGroups = [ "wheel" "media" ];
              packages = getUserPrograms username;
            }
            // (getUserMisc username);
          })
          enabledUsers);

        systemd.user.services = mkMerge (map getUserServices enabledUsers);

        hjem.users = listToAttrs (map
          (username: {
            name = username;
            value =
              {
                enable = true;
                user = username;
                directory = config.users.users.${username}.home;
                files = getUserDotfiles username;
              };
          })
          enabledUsers);
      })
    ];
}
