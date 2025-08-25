{ lib, ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = lib.mkDefault true;

  documentation = {
    doc.enable = false;
    info.enable = false;
  };
}
