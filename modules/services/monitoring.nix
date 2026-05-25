{
  config,
  self,
  pkgs,
  ...
}: {
  age.secrets.grafana-admin-password = {
    file = "${self}/secrets/grafana-admin-password.age";
    owner = "grafana";
    mode = "400";
  };

  age.secrets.grafana-secret-key = {
    file = "${self}/secrets/grafana-secret-key.age";
    owner = "grafana";
    mode = "400";
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server.http_listen_port = 3100;
      common = {
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
        replication_factor = 1;
        path_prefix = "/var/lib/loki";
      };
      schema_config.configs = [
        {
          from = "2024-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
    };
  };

  services.alloy = {
    enable = true;
    configPath = pkgs.writeText "alloy.alloy" ''
      loki.source.journal "caddy" {
        max_age    = "12h"
        labels     = {job = "caddy"}
        matches    = "_SYSTEMD_UNIT=caddy.service"
        forward_to = [loki.write.local.receiver]
      }

      loki.write "local" {
        endpoint {
          url = "http://localhost:3100/loki/api/v1/push"
        }
      }
    '';
  };

  services.prometheus = {
    enable = true;
    port = 9090;

    exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = ["systemd" "processes" "network_route"];
    };

    scrapeConfigs = [
      {
        job_name = "caddy";
        static_configs = [{targets = ["localhost:2019"];}];
      }
      {
        job_name = "node";
        static_configs = [{targets = ["localhost:9100"];}];
      }
    ];
  };

  services.grafana = {
    enable = true;

    settings.server = {
      http_addr = "127.0.0.1";
      http_port = 3001;
    };

    settings.security = {
      admin_user = "admin";
      admin_password = "$__file{${config.age.secrets.grafana-admin-password.path}}";
      secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
    };

    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
            isDefault = true;
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://localhost:3100";
          }
        ];
      };
    };
  };
}
