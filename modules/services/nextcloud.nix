{ config, ... }:
let
  lanIP = "192.168.0.227";
  wgIP = "10.0.0.2";
in
{
  # I use this to control what is visible for users/nextcloud
  # To allow nextcloud access, you'd have to run:
  # sudo chown -R <user>:smbnextcloud /talos/users/<user>
  # sudo chmod -R 2770 /talos/users/<user>
  # This way user still owns their folder
  users.groups.smbnextcloud = { };
  users.users.nextcloud.extraGroups = [ "smbnextcloud" "media" ];

  systemd.tmpfiles.rules = [
    "d /talos/services/nextcloud      0750 nextcloud nextcloud - -"
    "d /talos/services/nextcloud/data 0750 nextcloud nextcloud - -"
  ];

  systemd.services.nextcloud-setup.after = [ "zfs-mount.service" ];
  systemd.services.phpfpm-nextcloud.after = [ "zfs-mount.service" ];

  services.nextcloud = {
    enable = true;
    hostName = "talos.local";
    https = false;

    datadir = "/talos/services/nextcloud/data";

    configureRedis = true;
    database.createLocally = true;

    phpExtraExtensions = ps: [ ps.smbclient ];

    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = "/var/nextcloud-admin-pass";
    };

    settings = {
      trusted_domains = [ "talos" "talos.local" "192.168.0.227" "files.talosvault.net" ];
      trusted_proxies = [ "10.0.0.1/32" ];
      overwritehost = "files.talosvault.net";
      overwriteprotocol = "https";
      "overwrite.cli.url" = "https://files.talosvault.net";
      default_phone_region = "DK";
    };
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
    { addr = lanIP; port = 8080; ssl = false; }
    { addr = wgIP; port = 8080; ssl = false; }
  ];

}
