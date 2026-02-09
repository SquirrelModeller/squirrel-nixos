{pkgs, ...}: let
  lanIf = "enp4s0";
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
in {
  users.groups.shared = {};
  services.samba = {
    enable = true;
    openFirewall = false;
    nmbd.enable = false;
    settings = {
      global = {
        "server min protocol" = "SMB3";
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
        "mdns name" = "mdns";
        "multicast dns register" = "yes";
        "vfs objects" = "catia fruit streams_xattr acl_xattr";
        "fruit:model" = "MacSamba";

        # macOS-specific optimizations
        "fruit:aapl" = "yes";
        "fruit:nfs_aces" = "no";
        "fruit:copyfile" = "yes";
        "fruit:zero_file_id" = "yes";
      };
      homes = {
        comment = "Per-user ZFS home";
        path = "/talos/users/%S";
        browseable = false;
        "read only" = false;
        "guest ok" = false;
        "valid users" = ["%S"];
        "invalid users" = ["nobody"];
        "root preexec" = "${smbZfsEnsureMounted}/bin/smb-zfs-ensure-mounted %S";
        "root preexec close" = "yes";
      };
      shared = {
        path = "/talos/shared";
        browseable = true;
        "read only" = false;
        "guest ok" = false;
        "valid users" = ["@smbusers"];
        "create mask" = "0664";
        "directory mask" = "0775";
        "force group" = "smbusers";
      };
      media = {
        comment = "Shared Media";
        path = "/talos/media";
        browseable = true;
        "read only" = false;
        "valid users" = ["@media"];
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
        "valid users" = ["@smbusers"];
        "inherit permissions" = "yes";
        "inherit owner" = "yes";
        "create mask" = "0660";
        "directory mask" = "0770";
        "root preexec" = "${smbZfsEnsureMounted}/bin/smb-zfs-ensure-mounted %U";
        "root preexec close" = "yes";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    interface = lanIf;
    discovery = true;
  };
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
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
          <service>
            <type>_device-info._tcp</type>
            <port>9</port>
            <txt-record>model=MacSamba</txt-record>
          </service>
          <service>
            <type>_adisk._tcp</type>
            <port>9</port>
            <txt-record>sys=waMa=0,adVF=0x100</txt-record>
            <txt-record>dk0=adVN=shared,adVF=0x82</txt-record>
            <txt-record>dk1=adVN=media,adVF=0x82</txt-record>
          </service>
        </service-group>
      '';
    };
  };
  networking.firewall = {
    interfaces.${lanIf} = {
      allowedTCPPorts = [445];
      allowedUDPPorts = [137 138];
    };
  };
}
