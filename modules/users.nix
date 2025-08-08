{ config, lib, pkgs, availableUsers, getUserPrograms, ... }:

with lib;

{
  options = {
    squirrelOS.users.enabled = mkOption {
      type = types.listOf types.str;
      default = availableUsers;
      description = "List of user profiles to enable on this host";
      example = [ "squirrel" "guest" ];
    };

    squirrelOS.users.available = mkOption {
      type = types.listOf types.str;
      readOnly = true;
      default = availableUsers;
      description = "All available user profiles (auto-discovered)";
    };
  };

  config =
    let
      enabledUsers = config.squirrelOS.users.enabled;

      invalidUsers = filter (u: !(elem u availableUsers)) enabledUsers;

      assertion = {
        assertion = length invalidUsers == 0;
        message = "Unknown user profiles: ${toString invalidUsers}. Available: ${toString availableUsers}";
      };
    in
    mkIf (length enabledUsers > 0) {
      assertions = [ assertion ];

      users.users = listToAttrs (map
        (username: {
          name = username;
          value = {
            isNormalUser = true;
            home = "/home/${username}";
            shell = pkgs.bash;
            extraGroups = [ "wheel" ];
            packages = getUserPrograms pkgs username;
          };
        })
        enabledUsers);
    };
}
