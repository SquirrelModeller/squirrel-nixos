{ lib, self, ... }:
{
  imports = [
    ./fs
    "${self}/modules/options/host-context.nix"
    "${self}/modules/core"
    "${self}/modules/packages"
    "${self}/modules/terminal/zsh"
  ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];

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

  environment.etc."gai.conf".text = ''
    precedence ::ffff:0:0/96  100
  '';

  networking = {
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    hostName = "iris";

    interfaces.ens3.ipv4.addresses = [
      { address = "159.195.8.188"; prefixLength = 22; }
    ];
    defaultGateway = "159.195.8.1";

    enableIPv6 = false;
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.0.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/etc/wireguard/vps.key";
    peers = [
      {
        publicKey = "PdoaldW68gI55hL+8Xr888YG+FDaNAFrfH11r0ooE3s=";
        allowedIPs = [ "10.0.0.2/32" ];
        persistentKeepalive = 25;
      }
    ];
  };

  services.caddy = {
    enable = true;
    email = "squirrelmodeller@protonmail.com";

    virtualHosts."watch.talosvault.net".extraConfig = ''
      reverse_proxy 10.0.0.2:8096
    '';

    virtualHosts."files.talosvault.net".extraConfig = ''
      @carddav  path /.well-known/carddav
      @caldav   path /.well-known/caldav
      redir @carddav /remote.php/dav/ 301
      redir @caldav  /remote.php/dav/ 301

      reverse_proxy 10.0.0.2:8080
    '';
    virtualHosts."music.talosvault.net".extraConfig = ''
      reverse_proxy 10.0.0.2:4533
    '';

  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  squirrelOS.users.enabled = [ "squirrel" ];

  system.stateVersion = "25.05";
}
