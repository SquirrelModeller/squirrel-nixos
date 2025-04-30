{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (osConfig) modules;

  env = modules.usrEnv;
in {
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
          catppuccin.catppuccin-vsc
        ];
        userSettings = {
          "workbench.colorTheme" = "Catppuccin Mocha";
          "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
          "catppuccin.accentColor" = "mauve";

          "window.titleBarStyle" = "native";
          "telemetry.telemetryLevel" = "off";
          "update.showReleaseNotes" = false;
        };
      };
    };
  };
}
