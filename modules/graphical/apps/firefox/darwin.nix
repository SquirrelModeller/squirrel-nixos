{
  pkgs,
  firefoxShared,
  ...
}: let
  inherit (firefoxShared) mkMerge mkCssFile mkProfilesIni enabledUsers colors;

  mkPerUserFiles = username: let
    cssFile = mkCssFile username;
    profilesIni = mkProfilesIni username;

    # Darwin needs user.js for preferences since policies don't work
    userJs = pkgs.writeText "user-${username}.js" ''
      // Enable userChrome.css
      user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

      // Startup behaviour
      user_pref("browser.startup.page", 3);

      // UI
      user_pref("browser.toolbars.bookmarks.visibility", "never");
      user_pref("browser.tabs.allow_transparent_browser", true);
      user_pref("browser.display.background_color", "${colors.background}");

      // Telemetry / studies
      user_pref("toolkit.telemetry.enabled", false);
      user_pref("toolkit.telemetry.unified", false);
      user_pref("datareporting.healthreport.uploadEnabled", false);
      user_pref("app.shield.optoutstudies.enabled", false);

      // Pocket
      user_pref("extensions.pocket.enabled", false);

      // Newtab telemetry
      user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
      user_pref("browser.newtabpage.activity-stream.telemetry", false);

      // Reader / speech
      user_pref("reader.parse-on-load.enabled", false);
      user_pref("media.webspeech.synth.enabled", false);

      // Tracking protection
      user_pref("privacy.trackingprotection.enabled", true);
      user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
      user_pref("privacy.trackingprotection.cryptomining.enabled", true);
    '';
  in {
    "Library/Application Support/Firefox/profiles.ini".source = profilesIni;
    "Library/Application Support/Firefox/squirrel/user.js".source = userJs;
    "Library/Application Support/Firefox/squirrel/chrome/userChrome.css".source = cssFile;
  };
in {
  imports = [./default.nix];

  environment.systemPackages = with pkgs; [firefox];

  hjem.users = mkMerge (map (u: {${u}.files = mkPerUserFiles u;}) enabledUsers);
}
