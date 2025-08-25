{ lib, pkgs, modulesPath, self, ... }:
let
  systeminfo = pkgs.callPackage "${self}/modules/terminal/systeminfo" { };
in
{
  imports = [
    ./fs
    (modulesPath + "/installer/scan/not-detected.nix")
    "${self}/modules/core"
    "${self}/modules/hardware/cpu/amd.nix"
    "${self}/modules/hardware/gpu/amd.nix"
    "${self}/modules/graphical/apps"
    "${self}/modules/graphical/apps/quickshell.nix"
    "${self}/modules/graphical/theme/wallust-colorscheme.nix"
    "${self}/modules/graphical/wms/hyprland.nix"
    "${self}/modules/packages"
    "${self}/modules/terminal/security.nix"
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "uas" "sd_mod" ];
  };

  environment.variables = {
    systemPackages = [ systeminfo ];
    EDITOR = "vim";
    VISUAL = "vim";
  };

  modules = {
    usrEnv.programs.apps.firefox.enable = true;
    usrEnv.programs.apps.quickshell.enable = true;
    system.programs.gaming.steam.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "daedalus";

  squirrelOS.users.enabled = [ "squirrel" ];

  system.stateVersion = "24.11";

  time.timeZone = "Europe/Copenhagen";
  console.keyMap = "dk";
}
