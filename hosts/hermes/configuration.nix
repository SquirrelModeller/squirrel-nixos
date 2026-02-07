{
  config,
  lib,
  pkgs,
  self,
  ...
}:

let
  allUsers = [ "squirrel" ];
in
{
  squirrelOS.users.enabled = allUsers;

  imports = [
    "${self}/modules/options/host-context.nix"
    "${self}/modules/terminal/security/darwin.nix"
    "${self}/modules/packages/default.nix"
    "${self}/modules/graphical/apps/vscodium.nix"
  ];

  environment.systemPackages = [ pkgs.vim pkgs.firefox ];

  programs.direnv.enable = true;

  hjem.linker = pkgs.smfh;

  hjem.users.squirrel.directory = lib.mkForce "/Users/squirrel";
  users.users.squirrel.home = lib.mkForce "/Users/squirrel";

  security.pam.services.sudo_local.touchIdAuth = true;

  nix.settings.experimental-features = "nix-command flakes";
  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.stateVersion = 6;
}
