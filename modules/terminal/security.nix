{ pkgs, lib, ... }:
let
  u2fLines = [
    "squirrel:vtjRC1Qun6lE/+su1eOT0DpMEP33/kt34tS+vFMrQ5ytPSoCTisV6xbKUrj2KxV4wVm9ygspmuI3n3TYwSLI5g==,NKloYTARrswjUQg2h0oqdObwyqCHOGXRmqTsRrhKR/5vZMW7Dsf+4PTiZ3qil68hXDlwXvD9WUCZrPaUExHHFg==,es256,+presence"
  ];
in
{
  services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  environment.systemPackages = lib.attrValues {
    inherit (pkgs)
      openssh
      gnupg
      libfido2
      yubikey-manager;
  };

  security.pam.u2f = {
    enable = true;
    settings = {
      cue = true;
      authfile = "/etc/yubico/u2f_keys";
    };
  };

  security.pam.services.sudo.u2fAuth = true;

  environment.etc."yubico/u2f_keys" = {
    text = lib.concatStringsSep "\n" u2fLines + "\n";
    mode = "0400";
    user = "root";
    group = "root";
  };

  services.udev.packages = [ pkgs.yubikey-personalization ];
}
