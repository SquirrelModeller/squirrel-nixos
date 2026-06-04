{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkMerge;
in {
  _module.args.firefoxShared = {
    inherit mkMerge;

    mkProfilesIni = username:
      pkgs.writeText "profiles-${username}.ini" ''
        [General]
        StartWithLastProfile=1

        [Profile0]
        Name=squirrel
        IsRelative=1
        Path=squirrel
        Default=1
      '';

    enabledUsers = config.squirrelOS.users.enabled;
  };
}
