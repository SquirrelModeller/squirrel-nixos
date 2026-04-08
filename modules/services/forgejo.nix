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

  networking.firewall.allowedTCPPorts = [22 80 443 3000 2222];

  age.secrets.forgejo-admin-password = {
    file = "${self}/secrets/forgejo-admin-password.age";
    owner = "forgejo";
    group = "forgejo";
    mode = "400";
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
