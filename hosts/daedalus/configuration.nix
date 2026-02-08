{ lib, pkgs, modulesPath, self, ... }:
let
  systeminfo = pkgs.callPackage "${self}/modules/terminal/systeminfo" { };
in
{
  imports = [
    ./fs
    (modulesPath + "/installer/scan/not-detected.nix")
    "${self}/modules/options/host-context.nix"
    "${self}/modules/core"
    "${self}/modules/hardware/cpu/amd.nix"
    "${self}/modules/hardware/gpu/amd.nix"
    "${self}/modules/graphical/apps/firefox/nixos.nix"
    "${self}/modules/graphical/apps/quickshell.nix"
    "${self}/modules/graphical/apps/steam.nix"
    "${self}/modules/graphical/apps/vscodium.nix"
    "${self}/modules/graphical/apps/unicode-picker.nix"
    "${self}/modules/graphical/theme/wallust-colorscheme.nix"
    "${self}/modules/graphical/wms/hyprland.nix"
    "${self}/modules/graphical/dms/greetd.nix"
    "${self}/modules/packages"
    "${self}/modules/terminal/security/nixos.nix"
    "${self}/modules/terminal/zsh"
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "uas" "sd_mod" ];
    supportedFilesystems = [ "cifs" ];
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];

  environment.variables = {
    systemPackages = [ systeminfo ];
  };

  squirrelOS = {
    host.roles = [ "workstation" ];
    host.capabilities = { graphical = true; };
  };

  specialisation.gpu-passthrough.configuration = {
    system.nixos.tags = [ "gpu-passthrough" ];
    boot.kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
      "vfio-pci.ids=1002:744c,1002:ab30"
      "video=efifb:off"
    ];
    boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = false;
          swtpm.enable = true;
        };
      };
    };
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      looking-glass-client
      swtpm
    ];
    security.pam.loginLimits = [
      { domain = "@libvirtd"; item = "memlock"; type = "hard"; value = "unlimited"; }
      { domain = "@libvirtd"; item = "memlock"; type = "soft"; value = "unlimited"; }
    ];

    services.udev.extraRules = ''
      SUBSYSTEM=="vfio", OWNER="root", GROUP="libvirtd", MODE="0660"

      # I give access to all USB devices here
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0660", GROUP="libvirtd"
      KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="libvirtd"
    '';
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "daedalus";

  squirrelOS.users.enabled = [ "squirrel" ];

  system.stateVersion = "24.11";

  time.timeZone = "Europe/Copenhagen";
  console.keyMap = "dk";
}
