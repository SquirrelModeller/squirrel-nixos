{
  config,
  lib,
  getUserDotfiles,
  ...
}: let
  inherit (lib) mkIf;
  enabledUsers = config.squirrelOS.users.enabled;

  getUserVSCodiumFiles = username: let
    dotfiles = getUserDotfiles username;
    settingsPath = ".config/VSCodium/User/settings.json";

    hasSettings = dotfiles ? ${settingsPath};
  in
    if hasSettings
    then {
      "Library/Application Support/VSCodium/User/settings.json" = {
        source = dotfiles.${settingsPath}.source;
      };
    }
    else {};

  allVSCodiumFiles =
    lib.foldl' (
      acc: username:
        acc // (getUserVSCodiumFiles username)
    ) {}
    enabledUsers;
in {
  imports = [./default.nix];

  config = mkIf (enabledUsers != [] && allVSCodiumFiles != {}) {
    hjem.users = lib.genAttrs enabledUsers (username: {
      files = getUserVSCodiumFiles username;
    });
  };
}
