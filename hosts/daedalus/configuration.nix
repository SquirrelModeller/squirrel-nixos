{
  lib,
  pkgs,
  self,
  ...
}: {
  imports = [
    ./fs
    "${self}/modules/options/host-context.nix"
    "${self}/modules/core"
    "${self}/modules/hardware/cpu/amd.nix"
    "${self}/modules/hardware/gpu/amd.nix"
    "${self}/modules/graphical/apps/firefox/nixos.nix"
    "${self}/modules/graphical/apps/vscodium/nixos.nix"
    "${self}/modules/graphical/apps/unicode-picker.nix"
    "${self}/modules/graphical/wms/hyprland.nix"
    "${self}/modules/graphical/dms/greetd.nix"
    "${self}/modules/packages"
    "${self}/modules/terminal/security/nixos.nix"
    "${self}/modules/terminal/zsh"
  ];

  boot = {
    initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "uas" "sd_mod"];
    kernelModules = ["uinput"];
    supportedFilesystems = ["cifs"];
  };

  programs.fuse.enable = true;

  environment.systemPackages = with pkgs; [
    btrfs-progs
    cifs-utils
    samba
    # smbnetfs # this got dropped from packages :(
    quickshell
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="input", ENV{ID_VENDOR_ID}=="3434", ENV{ID_MODEL_ID}=="0251", ENV{ID_USB_INTERFACE_NUM}=="02", ENV{ID_INPUT_JOYSTICK}=""
  '';

  squirrelOS = {
    host.roles = ["workstation"];
    host.capabilities = {graphical = true;};
  };

  specialisation.gpu-passthrough.configuration = {
    system.nixos.tags = ["gpu-passthrough"];
    boot.kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
      "vfio-pci.ids=1002:744c,1002:ab30"
      "video=efifb:off"
    ];
    boot.initrd.kernelModules = ["vfio_pci" "vfio" "vfio_iommu_type1"];

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
      {
        domain = "@libvirtd";
        item = "memlock";
        type = "hard";
        value = "unlimited";
      }
      {
        domain = "@libvirtd";
        item = "memlock";
        type = "soft";
        value = "unlimited";
      }
    ];

    services.udev.extraRules = ''
      SUBSYSTEM=="vfio", OWNER="root", GROUP="libvirtd", MODE="0660"

      # I give access to all USB devices here
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0660", GROUP="libvirtd"
      KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="libvirtd"
    '';
  };

  security.pam.services.quickshell = {};

  hardware.bluetooth.enable = true;

  services = {
    upower.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    domacroc.enable = true;

    oo7.enable = true;

    dbus.packages = [pkgs.gcr];
  };

  networking = {
    firewall = {
      interfaces."enp15s0".allowedTCPPorts = [22];
    };
    networkmanager.enable = true;
    hostName = "daedalus";
    hosts."10.0.0.1" = ["monitor.talosvault.net"];

    wireguard.interfaces.wg0 = {
      ips = ["10.0.0.3/24"];
      privateKeyFile = "/var/lib/wireguard/daedalus.key";
      peers = [
        {
          publicKey = "S6uxm1oXW7qKXt2ubxylqgnKfsYBXh876++aySY+2zI=";
          endpoint = "159.195.8.188:51820";
          allowedIPs = ["10.0.0.1/32"];
          persistentKeepalive = 25;
        }
      ];
    };
  };

  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  nixpkgs.config = {
    allowUnfree = true;
    rocmSupport = true;
  };

  hardware.enableRedistributableFirmware = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  squirrelOS.users.enabled = ["squirrel"];

  system.stateVersion = "24.11";

  time.timeZone = "Europe/Copenhagen";
  console.keyMap = "dk";
}
