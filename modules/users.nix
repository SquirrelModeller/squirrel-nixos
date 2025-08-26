{ config, lib, pkgs, availableUsers, inputs, ... }:
let
  findFiles = import ../lib/findFiles.nix { inherit lib; };

  getUserDotfiles = username:
    let dotfilesDir = ../users + "/${username}/dotfiles";
    in if builtins.pathExists dotfilesDir then findFiles dotfilesDir else { };

  getUserServices = username:
    let servicesFile = ../users + "/${username}/services.nix";
    in if builtins.pathExists servicesFile
    then import servicesFile { inherit pkgs lib username inputs; }
    else { };

  inherit (lib) mkIf;
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
      assertion = {
        assertion = lib.length invalidUsers == 0;
        message = "Unknown user profiles: ${lib.toString invalidUsers}. Available: ${lib.toString availableUsers}";
      };
    in
    lib.mkMerge [
      (mkIf (lib.length enabledUsers > 0) {
        assertions = [ assertion ];

        users.users = lib.listToAttrs (lib.map
          (username: {
            name = username;
            value = {
              isNormalUser = true;
              home = "/home/${username}";
              shell = pkgs.zsh;
              extraGroups = [ "wheel" ];
              packages =
                let programsFile = ../users + "/${username}/programs/default.nix";
                in import programsFile {
                  inherit pkgs inputs lib;
                  colors = config.modules.style.colorScheme.colors;
                };
            };
          })
          enabledUsers);

        systemd.user.services =
          lib.mkMerge (lib.map (username: getUserServices username) enabledUsers);

        hjem.users = lib.listToAttrs (lib.map
          (username: {
            name = username;
            value = {
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
