{
  firefoxShared,
  ...
}: let
  inherit (firefoxShared) mkMerge mkCssFile mkProfilesIni enabledUsers colors;

  mkPerUserFiles = username: let
    cssFile = mkCssFile username;
    profilesIni = mkProfilesIni username;
  in {
    ".mozilla/firefox/profiles.ini".source = profilesIni;
    ".mozilla/firefox/squirrel/chrome/userChrome.css".source = cssFile;
  };
in {
  imports = [./default.nix];

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      LegacyProfiles = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      SearchEngines = {
        Default = "DuckDuckGo";
        Order = ["DuckDuckGo" "Google"];
      };
      Preferences = {
        "browser.newtabpage.activity-stream.feeds.telemetry" = {
          Value = false;
          Status = "locked";
        };
        "browser.newtabpage.activity-stream.telemetry" = {
          Value = false;
          Status = "locked";
        };
        "reader.parse-on-load.enabled" = {Value = false;};
        "media.webspeech.synth.enabled" = {Value = false;};
        "toolkit.legacyUserProfileCustomizations.stylesheets" = {
          Value = true;
        };
        "browser.startup.page" = {Value = 3;};
        "browser.toolbars.bookmarks.visibility" = {Value = "never";};
        "browser.tabs.allow_transparent_browser" = {Value = true;};
        "browser.display.background_color" = {Value = colors.background;};
      };
    };
  };

  hjem.users = mkMerge (map (u: {${u}.files = mkPerUserFiles u;}) enabledUsers);
}
