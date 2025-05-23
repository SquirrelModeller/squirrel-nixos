{ lib
, pkgs
, osConfig
, ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;

  env = modules.usrEnv;
in
{
  config = mkIf env.programs.apps.vscodium.enable {
    home.packages = with pkgs; [
      vscodium
    ];
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      profiles.default = {
        enableExtensionUpdateCheck = true;
        enableUpdateCheck = true;
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          kamadorueda.alejandra
        ];
        userSettings = {
          "window.titleBarStyle" = "native";
          "telemetry.telemetryLevel" = "off";
          "update.showReleaseNotes" = false;
        };
      };
    };
  };
}
