{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/Copenhagen";

  console.keyMap = "dk";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  hardware.graphics.enable = true;

  networking.hostName = "modeller";

  documentation = {
    doc.enable = false;
    info.enable = false;
  };

  system.stateVersion = "24.11";
}
