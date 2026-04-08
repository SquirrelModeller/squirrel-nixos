{
  lib,
  self,
  ...
}: {
  imports = [
    ./fs
    "${self}/modules/options/host-context.nix"
    "${self}/modules/core"
    "${self}/modules/packages"
    "${self}/modules/terminal/zsh"
    "${self}/modules/notifications/gotify-rebuild-notify.nix"
  ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk"];

  squirrelOS = {
    host.roles = ["server"];
    host.capabilities = {graphical = false;};
  };

  squirrelOS.notifications.gotify = {
    enable = true;
    serverUrl = "https://notify.talosvault.net";
  };

  services.openssh = {
    enable = true;
    ports = [2222];
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
    hostName = "iris";

    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "159.195.8.188";
          prefixLength = 22;
        }
      ];

      ipv6.addresses = [
        {
          address = "2a0a:4cc0:ff:a44::2";
          prefixLength = 64;
        }
      ];
    };

    defaultGateway = "159.195.8.1";

    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };

    nameservers = ["1.1.1.1" "8.8.8.8"];
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [2222 22 80 443];
    allowedUDPPorts = [51820 34197];

    extraCommands = ''
      # Allow forwarding of UDP traffic to Factorio server
      iptables -A FORWARD -i ens3 -o wg0 -p udp --dport 34197 -d 10.0.0.2 -j ACCEPT
      iptables -A FORWARD -i wg0 -o ens3 -p udp --sport 34197 -s 10.0.0.2 -j ACCEPT
      iptables -t nat -A POSTROUTING -o wg0 -d 10.0.0.2 -p udp --dport 34197 -j MASQUERADE

      iptables -A FORWARD -i ens3 -o wg0 -p tcp --dport 2222 -d 10.0.0.2 -j ACCEPT
      iptables -A FORWARD -i wg0 -o ens3 -p tcp --sport 2222 -s 10.0.0.2 -j ACCEPT
      iptables -t nat -A POSTROUTING -o wg0 -d 10.0.0.2 -p tcp --dport 2222 -j MASQUERADE
    '';
  };

  networking.wireguard.interfaces.wg0 = {
    ips = ["10.0.0.1/24"];
    listenPort = 51820;
    privateKeyFile = "/etc/wireguard/vps.key";
    peers = [
      {
        publicKey = "PdoaldW68gI55hL+8Xr888YG+FDaNAFrfH11r0ooE3s=";
        allowedIPs = ["10.0.0.2/32"];
        persistentKeepalive = 25;
      }
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.nat = {
    enable = true;
    externalInterface = "ens3";
    internalInterfaces = ["wg0"];

    internalIPs = ["10.0.0.0/24"];

    forwardPorts = [
      {
        sourcePort = 34197;
        proto = "udp";
        destination = "10.0.0.2:34197";
      }

      {
        sourcePort = 22;
        proto = "tcp";
        destination = "10.0.0.2:2222";
      }
    ];
  };

  services.caddy = {
    enable = true;
    email = "squirrelmodeller@protonmail.com";

    virtualHosts = {
      "watch.talosvault.net".extraConfig = ''
        reverse_proxy 10.0.0.2:8096
      '';

      "files.talosvault.net".extraConfig = ''
        @carddav  path /.well-known/carddav
        @caldav   path /.well-known/caldav
        redir @carddav /remote.php/dav/ 301
        redir @caldav  /remote.php/dav/ 301
        reverse_proxy 10.0.0.2:8080
      '';

      "music.talosvault.net".extraConfig = ''
        reverse_proxy 10.0.0.2:4533
      '';

      "notify.talosvault.net".extraConfig = ''
        reverse_proxy 10.0.0.2:8090
      '';

      "vault.talosvault.net".extraConfig = ''
        reverse_proxy 10.0.0.2:8000
        reverse_proxy /notifications/hub 10.0.0.2:3012
        reverse_proxy /notifications/hub/negotiate 10.0.0.2:8000
      '';

      "sendiron.talosvault.net".extraConfig = ''
        respond "Factorio server running on UDP port 34197"
      '';

      "squirrel.talosvault.net".extraConfig = ''
        header {
          Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
          Pragma "no-cache"
          Expires "0"
        }
        reverse_proxy 10.0.0.2:3975
      '';

      "git.talosvault.net".extraConfig = ''
        reverse_proxy 10.0.0.2:3000
      '';
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  squirrelOS.users.enabled = ["squirrel"];

  system.stateVersion = "25.05";
}
