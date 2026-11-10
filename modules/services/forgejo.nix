{
  config,
  self,
  lib,
  ...
}: let
  cfg = config.services.forgejo;
  adminCmd = "${lib.getExe cfg.package} admin user";
  domain = "git.talosvault.net";
in {
  services.postgresql = {
    enable = true;
    ensureDatabases = ["forgejo"];
    ensureUsers = [
      {
        name = "forgejo";
        ensureDBOwnership = true;
      }
    ];
  };

  services.forgejo = {
    enable = true;

    database = {
      type = "postgres";
      host = "/run/postgresql";
      name = "forgejo";
      user = "forgejo";
    };

    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}/";
        HTTP_ADDR = "0.0.0.0";
        HTTP_PORT = 3000;

        SSH_DOMAIN = domain;
        SSH_LISTEN_PORT = 2222;
        SSH_PORT = 22;
        START_SSH_SERVER = true;
      };

      service = {
        DISABLE_REGISTRATION = true;
      };

      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };

      session = {
        COOKIE_SECURE = true;
      };

      security = {
        INSTALL_LOCK = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "squirrelmodeller@protonmail.com";
  };

  networking.firewall = {
    interfaces."lan0".allowedTCPPorts = [3000 2222];
    interfaces.wg0.allowedTCPPorts = [3000 2222];
  };

  age.secrets.forgejo-admin-password = {
    file = "${self}/secrets/forgejo-admin-password.age";
    owner = "forgejo";
    group = "forgejo";
    mode = "400";
  };

  # Git hooks call back into forgejo over localhost, so loopback must stay allowed.
  systemd.services.forgejo.serviceConfig = {
    ProtectSystem = lib.mkForce "strict";
    ProtectHome = true;
    PrivateTmp = true;
    NoNewPrivileges = true;
    LockPersonality = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    SystemCallArchitectures = "native";
    ProtectHostname = true;
    ProtectClock = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    KeyringMode = "private";
    RemoveIPC = true;
    UMask = lib.mkForce "0077";
    AmbientCapabilities = lib.mkForce [""];
    CapabilityBoundingSet = lib.mkForce [""];
    RestrictAddressFamilies = lib.mkForce ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
    SystemCallFilter = ["@system-service" "~@privileged"];
    # Inbound from iris (git.talosvault.net), SSH via iris, and LAN clients. Outbound internet
    # stays open for DEFAULT_ACTIONS_URL (github) and mirrors; other private ranges are denied.
    IPAddressDeny = ["10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"];
    IPAddressAllow = [
      "localhost"
      "10.0.0.1"
      "192.168.0.0/24"
    ];
  };

  systemd.services.forgejo.preStart = ''
    ${adminCmd} create \
      --admin \
      --email "squirrelmodeller@protonmail.com" \
      --username "squirrel" \
      --password "$(tr -d '\n' < ${config.age.secrets.forgejo-admin-password.path})" \
      || true
  '';
}
