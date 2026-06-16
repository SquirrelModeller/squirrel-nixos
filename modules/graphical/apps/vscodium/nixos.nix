{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  enabledUsers = config.squirrelOS.users.enabled;

  vscodeExtensions = import ./extensions.nix pkgs;

  extensionsDrv = pkgs.buildEnv {
    name = "vscodium-extensions";
    paths =
      vscodeExtensions
      ++ [
        (pkgs.writeTextFile {
          name = "vscodium-extensions-json";
          destination = "/share/vscode/extensions/extensions.json";
          text = pkgs.vscode-utils.toExtensionJson vscodeExtensions;
        })
      ];
  };
in {
  imports = [./default.nix];

  config = mkIf (enabledUsers != []) {
    hjem.users = lib.genAttrs enabledUsers (username: {
      files = {
        ".vscode-oss/extensions" = {
          source = "${extensionsDrv}/share/vscode/extensions";
        };
      };
    });
  };
}
