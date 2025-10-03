{ lib, pkgs, modulesPath, self, ... }:
{
  imports = [
    ./fs
    (modulesPath + "/installer/scan/not-detected.nix")
    "${self}/modules/options/host-context.nix"
    "${self}/modules/core"
    "${self}/modules/packages"
    "${self}/modules/terminal/zsh"
    "${self}/modules/services/jellyfin.nix"
    "${self}/modules/services/nextcloud.nix"
    "${self}/modules/services/navidrome.nix"
    "${self}/modules/services/samba.nix"
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    initrd.availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "uas" "sd_mod" ];
    zfs.extraPools = [ "talos" ];
    zfs.requestEncryptionCredentials = false;
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

  security.sudo.extraRules = [{
    users = [ "squirrel" ];
    commands = [
      { command = "/run/current-system/sw/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
    ];
  }];

  networking.hostId = "0e0a5617";
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = false;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      hinfo = true;
    };
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.0.0.2/24" ];
    privateKeyFile = "/var/lib/wireguard/talos.key";
    peers = [{
      publicKey = "S6uxm1oXW7qKXt2ubxylqgnKfsYBXh876++aySY+2zI=";
      endpoint = "159.195.8.188:51820";
      allowedIPs = [ "10.0.0.1/32" ];
      persistentKeepalive = 25;
    }];
  };

  networking.firewall = {
    enable = true;

    interfaces."enp3s0" = {
      allowedTCPPorts = [ 22 8080 4533 8096 445 ];
      allowedUDPPorts = [ 137 138 5353 ];
    };

    interfaces.wg0 = {
      allowedTCPPorts = [ 8080 4533 8096 ];
      allowedUDPPorts = [ ];
    };

    extraCommands = ''
      iptables -I FORWARD -i wg0 -d 192.168.0.0/16 -j DROP
      iptables -I FORWARD -o wg0 -s 192.168.0.0/16 -j DROP
    
      iptables -I FORWARD -i wg0 -d 10.0.0.0/8 -j DROP
      iptables -I FORWARD -i wg0 -d 172.16.0.0/12 -j DROP
    '';
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "talos";

  squirrelOS.users.enabled = [ "squirrel" ];

  system.stateVersion = "25.05";

  time.timeZone = "Europe/Copenhagen";
  console.keyMap = "dk";
}
