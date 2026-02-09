{pkgs, ...}: {
  imports = [./default.nix];

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-tty;

  services.pcscd.enable = true;

  security.pam.u2f = {
    enable = true;
    settings = {
      cue = true;
      authfile = "/etc/yubico/u2f_keys";
    };
  };

  security.pam.services.sudo.u2fAuth = true;

  environment.etc."yubico/u2f_keys" = {
    mode = "0400";
    user = "root";
    group = "root";
  };

  services.udev.packages = with pkgs; [
    yubikey-personalization
    yubikey-manager
  ];
}
