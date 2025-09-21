{ lib, modulesPath, self, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    "${self}/modules/options/host-context.nix"
    "${self}/modules/core"
    "${self}/modules/packages"
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "uas" "sd_mod" ];
  };

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  squirrelOS = {
    host.roles = [ "server" ];
    host.capabilities = { graphical = false; };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "talos";

  squirrelOS.users.enabled = [ "squirrel" ];

  system.stateVersion = "24.11";

  time.timeZone = "Europe/Copenhagen";
  console.keyMap = "dk";
}
