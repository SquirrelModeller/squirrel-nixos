{ config
, lib
, pkgs
, osConfig
, ...
}:
let
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

  privacy = {
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "datareporting.usage.uploadEnabled" = false;
  };
in
{
  config = mkIf env.programs.apps.firefox.enable {
    programs.firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = false;
          search = {
            force = true;
            default = "ddg";
            order = [ "ddg" "google" ];
          };
          settings = privacy;
        };

        squirrel = {
          id = 1;
          name = "squirrel";
          isDefault = true;
          search = {
            force = true;
            default = "ddg";
            order = [ "ddg" "google" ];
          };
          settings = privacy // {
            "browser.startup.page" = 3;
            "browser.toolbars.bookmarks.visibility" = "never";
          };
        };
      };

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DontCheckDefaultBrowser = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        Preferences = {
          "browser.newtabpage.activity-stream.feeds.telemetry" = lock-false;
          "browser.newtabpage.activity-stream.telemetry" = lock-false;
        };
      };
    };
  };
}
