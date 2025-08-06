{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics.enable = true;

  documentation = {
    doc.enable = false;
    info.enable = false;
  };

  system.stateVersion = "24.11";
}
