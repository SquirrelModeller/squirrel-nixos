{ lib, pkgs, modulesPath, self, ... }:
let
  lanIf = "enp3s0";
  lanIP = "192.168.0.227";
  wgIP = "10.0.0.2";
  vpsWGIP = "10.0.0.1";

  smbZfsEnsureMounted = pkgs.writeShellScriptBin "smb-zfs-ensure-mounted" ''
    set -eu
    user="''${1:-}"
    [ -n "$user" ] || exit 1

    ds="talos/users/$user"

    if ! ${pkgs.zfs}/bin/zfs list -H "$ds" >/dev/null 2>&1; then
      exit 0
    fi

    ks="$(${pkgs.zfs}/bin/zfs get -H -o value keystatus "$ds" 2>/dev/null || echo "-")"

    if [ "$ks" = "unavailable" ]; then
      ${pkgs.zfs}/bin/zfs load-key "$ds" || exit 1
    fi

    mounted="$(${pkgs.zfs}/bin/zfs get -H -o value mounted "$ds" 2>/dev/null || echo "no")"
    if [ "$mounted" != "yes" ]; then
      ${pkgs.zfs}/bin/zfs mount "$ds" || exit 1
    fi
  '';
in
{
  imports = [
    ./fs
    (modulesPath + "/installer/scan/not-detected.nix")
    "${self}/modules/options/host-context.nix"
    "${self}/modules/core"
    "${self}/modules/packages"
    "${self}/modules/terminal/zsh"

    "${self}/modules/services/jellyfin.nix"
    "${self}/modules/services/navidrome.nix"
    "${self}/modules/services/nextcloud.nix"
    ./shares.nix
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    initrd.availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "uas" "sd_mod" ];
    zfs.extraPools = [ "talos" ];
    zfs.requestEncryptionCredentials = false;
  };

  environment.systemPackages = [ smbZfsEnsureMounted ];

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

  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    openFirewall = false;

    settings = {
      global = {
        "server min protocol" = "SMB3";
        "vfs objects" = "catia fruit streams_xattr acl_xattr";
        "ea support" = true;
        "map acl inherit" = true;
        "store dos attributes" = true;

        "smb ports" = "445";

        "security" = "user";

        "guest account" = "nobody";

        "fruit:metadata" = "stream";
        "fruit:resource" = "stream";
        "fruit:locking" = "netatalk";
        "fruit:encoding" = "native";

        "workgroup" = "WORKGROUP";
        "server string" = "Talos NAS";

        "map to guest" = "Never";
        "restrict anonymous" = "2";
        "access based share enum" = true;
        "hide unreadable" = true;

        "interfaces" = "${lanIf} lo";
        "bind interfaces only" = "yes";
        "hosts allow" = "127.0.0.1 192.168.0.0/16";
        "hosts deny" = "0.0.0.0/0";
      };

      homes = {
        comment = "Per-user ZFS home";
        path = "/talos/users/%S";
        browseable = false;
        "read only" = false;
        "guest ok" = false;
        "valid users" = [ "%S" ];
        "invalid users" = [ "nobody" ];
        "root preexec" = "${smbZfsEnsureMounted}/bin/smb-zfs-ensure-mounted %S";
        "root preexec close" = "yes";
      };

      shared = {
        path = "/talos/shared";
        browseable = true;
        "read only" = false;
        "guest ok" = false;
        "valid users" = [ "@smbusers" ];
        "create mask" = "0664";
        "directory mask" = "0775";
        "force group" = "smbusers";
      };

      media = {
        comment = "Shared Media";
        path = "/talos/media";
        browseable = true;
        "read only" = false;

        "valid users" = [ "@media" ];

        "create mask" = "0664";
        "directory mask" = "2775";
        "inherit permissions" = "yes";
        "inherit owner" = "yes";
      };

      users = {
        comment = "Per-user roots";
        path = "/talos/users";
        browseable = false;
        "read only" = false;
        "guest ok" = false;
        "valid users" = [ "@smbusers" ];
        "inherit permissions" = "yes";
        "inherit owner" = "yes";
        "create mask" = "0660";
        "directory mask" = "0770";

        "root preexec" = "${smbZfsEnsureMounted}/bin/smb-zfs-ensure-mounted %U";
        "root preexec close" = "yes";
      };

    };
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "${wgIP}/24" ];
    privateKeyFile = "/var/lib/wireguard/talos.key";
    peers = [{
      publicKey = "sl9IkwyMDPdZTYqUSkTV06uTReccZADeuJOgI1UoOFU=";
      endpoint = "159.195.8.188:51820";
      allowedIPs = [ "${vpsWGIP}/32" ];
      persistentKeepalive = 25;
    }];
  };

  networking.firewall = {
    enable = true;

    interfaces.${lanIf} =
      {
        allowedTCPPorts = [ 22 8080 4533 8096 445 139 80 ];
        allowedUDPPorts = [ 137 138 5353 ]; # Samba nmbd
      };

    interfaces.wg0.allowedTCPPorts = [ ];
    interfaces.wg0.allowedUDPPorts = [ ];

    extraCommands = ''
      # Default: DROP all traffic from wg0 interface
      iptables -I nixos-fw -i wg0 -j nixos-fw-refuse
  
      # Exception: Allow ONLY VPS to ONLY these service ports
      iptables -I nixos-fw -i wg0 -p tcp -m multiport --dports 8080,4533,8096 -s ${vpsWGIP} -j nixos-fw-accept
  
      # Allow established connections back (for responses)
      iptables -I nixos-fw -i wg0 -m state --state ESTABLISHED,RELATED -j nixos-fw-accept

      iptables -I FORWARD -i wg0 -d 192.168.0.0/16 -j DROP
      iptables -I FORWARD -o wg0 -s 192.168.0.0/16 -j DROP
    '';

    logRefusedConnections = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts."talos" = {
      default = true;
      listen = [
        { addr = lanIP; port = 80; }
        { addr = "10.0.0.2"; port = 80; }
      ];
      root = "/etc/nginx/talos";

      locations."/jellyfin/" = {
        proxyPass = "http://127.0.0.1:8096/";
        proxyWebsockets = true;
      };

      locations."= /music" = { return = "301 /music/"; };
      locations."/music/" = {
        proxyPass = "http://127.0.0.1:4533/";
        proxyWebsockets = true;
      };
    };
  };


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "talos";

  squirrelOS.users.enabled = [ "squirrel" ];

  system.stateVersion = "25.05";

  time.timeZone = "Europe/Copenhagen";
  console.keyMap = "dk";
}
