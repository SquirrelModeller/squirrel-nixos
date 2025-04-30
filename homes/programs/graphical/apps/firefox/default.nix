{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
  inherit (lib) mkIf getExe;
  inherit (osConfig) modules;

  env = modules.usrEnv;
in {
  config = mkIf env.programs.apps.firefox.enable {
    home.packages = with pkgs; [
      firefox
    ];
    programs.firefox = {
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DontCheckDefaultBrowser = true;
        Preferences = {
          # It seems these policies are not being applied
          # Maybe they only apply on a fresh browser?
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.archive.enabled" = false;
        };
      };
    };
  };
}
