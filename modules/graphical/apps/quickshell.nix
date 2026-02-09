{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkMerge;

  enabledUsers = config.squirrelOS.users.enabled;

  srcFor = u: let
    perUser = "${inputs.self}/users/${u}/quickshell-src";
    # Fallback for now is Squirrel (my) quickshell
    # TODO: Make a default fallback?
    common = "${inputs.self}/users/squirrel/quickshell-src/";
  in
    if builtins.pathExists perUser
    then perUser
    else if builtins.pathExists common
    then common
    else null;
in {
  hjem.users = mkMerge (map
    (
      u: let
        src = srcFor u;
      in
        if src == null
        then {}
        else {
          ${u}.files.".config/quickshell".source = src;
        }
    )
    enabledUsers);
}
