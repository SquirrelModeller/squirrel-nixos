{
  lib,
  pkgs,
  self,
  ...
}: let
  allUsers = ["squirrel"];
in {
  squirrelOS.users.enabled = allUsers;

  imports = [
    "${self}/modules/options/host-context.nix"
    "${self}/modules/terminal/security/darwin.nix"
    "${self}/modules/packages/default.nix"
    "${self}/modules/graphical/apps/vscodium/darwin.nix"
    "${self}/modules/graphical/apps/firefox/darwin.nix"
  ];

  environment.systemPackages = [pkgs.vim];

  programs.direnv.enable = true;

  hjem.linker = pkgs.smfh;

  hjem.users.squirrel.directory = lib.mkForce "/Users/squirrel";
  users.users.squirrel.home = lib.mkForce "/Users/squirrel";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.dock = {
    autohide = true;
    persistent-apps = [];
    persistent-others = [];
    tilesize = 50;
  };

  networking = {
    hostName = "hermes";
    localHostName = "hermes";
    computerName = "hermes";
  };

  system = {
    defaults = {
      CustomUserPreferences = {
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = false;
        };
      };
    };

    defaults.NSGlobalDomain = {
      "com.apple.swipescrolldirection" = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
    configurationRevision = self.rev or self.dirtyRev or null;

    stateVersion = 6;
  };

  nix.settings.experimental-features = "nix-command flakes";
}
