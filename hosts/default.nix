{lib, ...}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = lib.mkDefault true;

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    NH_OS_FLAKE = "/home/squirrel/squirrel-nixos";
  };

  documentation = {
    doc.enable = false;
    info.enable = false;
  };
}
