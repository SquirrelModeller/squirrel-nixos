{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkMerge;
  colors = config.modules.style.colorScheme.colors;

  renderCss = cssTemplate:
    lib.strings.replaceStrings
    ["base00" "base01" "base02" "base03" "base99"]
    [
      colors.base00
      colors.base01
      colors.base02
      colors.base03
      colors.background
    ]
    cssTemplate;
in {
  _module.args.firefoxShared = {
    inherit mkMerge colors;

    mkCssFile = username: let
      cssTemplate = builtins.readFile (./userChrome.css);
    in
      pkgs.writeText "userChrome-${username}.css" (renderCss cssTemplate);

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
