{ config, pkgs, lib, self }:
{
  imports = [
    ./fs
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

  networking.useDHCP = false;
  networking.interfaces.ens3.ipv4.addresses = [
    { address = "159.195.8.188"; prefixLength = 22; }
  ];

  networking.defaultGateway = "159.195.8.1";

  networking.interfaces.ens3.ipv6.addresses = [
    { address = "2a0a:4cc0:ff:a44::1"; prefixLength = 64; }
  ];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens3";
  };


  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ 443 51820 ];
  };


  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.0.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/etc/wireguard/wg0.key";
    peers = [
      {
        publicKey = "Lq3Ko7nioCu2/2t7l+bMMiIz7jahkxKvYq1PZgMkMS0=";
        allowedIPs = [ "10.0.0.2/32" ];
        persistentKeepalive = 25;
      }
    ];
  };


  security.acme = {
    acceptTerms = true;
    defaults.email = "squirrelmodeller@protonmail.com";
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      "talosvault.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/".return = "301 https://files.talosvault.net$request_uri";
      };
      "www.talosvault.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/".return = "301 https://files.talosvault.net$request_uri";
      };

      "music.talosvault.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://10.0.0.2:4533/";
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_request_buffering off;
            proxy_buffering off;
            proxy_read_timeout 3600;
          '';
        };
      };

      "watch.talosvault.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://10.0.0.2:8096/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_read_timeout 3600;
            proxy_send_timeout 3600;
          '';
        };
      };

      "files.talosvault.net" = {
        enableACME = true;
        forceSSL = true;

        extraConfig = ''
          add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
        '';

        locations."=/.well-known/carddav".return = "301 /remote.php/dav/";
        locations."=/.well-known/caldav".return = "301 /remote.php/dav/";

        locations."/" = {
          proxyPass = "http://10.0.0.2:8080";
          extraConfig = ''
            client_max_body_size 10240M;
            proxy_http_version 1.1;
            proxy_request_buffering off;
            proxy_buffering off;
            proxy_read_timeout 3600;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Port 443;
          '';
        };
      };
    };
  };


  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "iris";

  squirrelOS.users.enabled = [ "squirrel" ];

  system.stateVersion = "25.05";

  time.timeZone = "Europe/Copenhagen";
  console.keyMap = "dk";

}
