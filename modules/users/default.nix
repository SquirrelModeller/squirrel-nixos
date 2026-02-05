{
  config,
  lib,
  pkgs,
  inputs,
  self,
  availableUsers,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    listToAttrs
    map
    ;
  findFiles = import ../lib/findFiles.nix { inherit lib; };

  getUserDotfiles =
    username:
    let
      dotfilesDir = ../users + "/${username}/dotfiles";
    in
    if builtins.pathExists dotfilesDir then findFiles dotfilesDir else { };

  getUserMisc =
    username:
    let
      f = "${self}/users/${username}/misc.nix";
    in
    if builtins.pathExists f then import f { } else { };

  getUserProgramsPath = username: "${self}/users/${username}/programs/default.nix";

  enabledUsers = config.squirrelOS.users.enabled;
  invalidUsers = lib.filter (u: !(lib.elem u availableUsers)) enabledUsers;
in
{
  options = {
    squirrelOS.users.enabled = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = availableUsers;
      description = "List of user profiles to enable on this host";
      example = [
        "squirrel"
        "guest"
      ];
    };

    squirrelOS.users.available = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      default = availableUsers;
      description = "All available user profiles (auto-discovered)";
    };
  };

  config = mkMerge [
    {
      _module.args = {
        inherit getUserProgramsPath getUserMisc getUserDotfiles;
      };
    }

    (mkIf (enabledUsers != [ ]) {
      assertions = [
        {
          assertion = lib.length invalidUsers == 0;
          message =
            "Unknown user profiles: ${lib.toString invalidUsers}. "
            + "Available: ${lib.toString availableUsers}";
        }
      ];

      hjem.users = listToAttrs (
        map (username: {
          name = username;
          value = {
            enable = true;
            user = username;
            directory = config.users.users.${username}.home;
            files = getUserDotfiles username;
          };
        }) enabledUsers
      );

      hjem.clobberByDefault = true;
    })
  ];
}
