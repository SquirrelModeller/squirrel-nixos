{
  config,
  pkgs,
  lib,
  ...
}: let
  promDS = {
    type = "prometheus";
    uid = "prometheus";
  };

  lokiDS = {
    type = "loki";
    uid = "loki";
  };

  mkPromTarget = {
    expr,
    legendFormat ? "",
    refId ? "A",
  }: {
    datasource = promDS;
    editorMode = "code";
    inherit expr legendFormat refId;
    instant = false;
    range = true;
  };

  mkLokiTarget = {
    expr,
    legendFormat ? "",
    refId ? "A",
    queryType ? "range",
  }: {
    datasource = lokiDS;
    editorMode = "code";
    inherit expr legendFormat refId queryType;
  };

  mkTimeseries = {
    id,
    title,
    description ? "",
    datasource,
    targets,
    gridPos,
    unit ? "short",
    fillOpacity ? 20,
    lineWidth ? 2,
  }: {
    inherit id title description datasource targets gridPos;
    type = "timeseries";
    fieldConfig = {
      defaults = {
        color = {mode = "palette-classic";};
        custom = {
          axisBorderShow = false;
          axisCenteredZero = false;
          axisColorMode = "text";
          axisLabel = "";
          axisPlacement = "auto";
          barAlignment = 0;
          drawStyle = "line";
          inherit fillOpacity lineWidth;
          gradientMode = "scheme";
          hideFrom = {
            legend = false;
            tooltip = false;
            viz = false;
          };
          insertNulls = false;
          lineInterpolation = "linear";
          pointSize = 5;
          scaleDistribution = {type = "linear";};
          showPoints = "never";
          spanNulls = false;
          stacking = {
            group = "A";
            mode = "none";
          };
          thresholdsStyle = {mode = "off";};
        };
        mappings = [];
        thresholds = {
          mode = "absolute";
          steps = [
            {
              color = "green";
              value = null;
            }
          ];
        };
        inherit unit;
      };
      overrides = [];
    };
    options = {
      legend = {
        calcs = ["mean" "lastNotNull" "max"];
        displayMode = "table";
        placement = "bottom";
        showLegend = true;
      };
      tooltip = {
        hideZeros = false;
        mode = "multi";
        sort = "desc";
      };
    };
  };

  # Blog traffic row

  rowBlogTraffic = {
    type = "row";
    id = 1;
    title = "Blog Traffic";
    collapsed = false;
    gridPos = {
      h = 1;
      w = 24;
      x = 0;
      y = 0;
    };
    panels = [];
  };

  panelBlogPageViewsRange = mkTimeseries {
    id = 2;
    title = "Blog Page Views (full range)";
    description = "Hit count per blog URI aggregated over the selected dashboard time range. Use this to compare relative popularity of posts.";
    datasource = lokiDS;
    gridPos = {
      h = 8;
      w = 24;
      x = 0;
      y = 1;
    };
    unit = "short";
    fillOpacity = 15;
    lineWidth = 2;
    targets = [
      (mkLokiTarget {
        expr = ''sum by (request_uri) (count_over_time({job="caddy"} | json | request_host="squirrel.talosvault.net" | request_uri=~"/blog/.*"[$__range]))'';
        legendFormat = "{{request_uri}}";
        refId = "A";
      })
    ];
  };

  panelBlogPageViews5m = mkTimeseries {
    id = 3;
    title = "Blog Page Views (5m rate)";
    description = "Rolling 5-minute hit count per blog URI. Shows short-term traffic bursts, e.g. from a link being shared.";
    datasource = lokiDS;
    gridPos = {
      h = 8;
      w = 24;
      x = 0;
      y = 9;
    };
    unit = "short";
    fillOpacity = 10;
    lineWidth = 2;
    targets = [
      (mkLokiTarget {
        expr = ''sum by (request_uri) (count_over_time({job="caddy"} | json | request_host="squirrel.talosvault.net" | request_uri=~"/blog/.*"[5m]))'';
        legendFormat = "{{request_uri}}";
        refId = "A";
      })
    ];
  };

  # Caddy HTTP traffic row

  rowCaddyTraffic = {
    type = "row";
    id = 10;
    title = "Caddy HTTP Traffic";
    collapsed = false;
    gridPos = {
      h = 1;
      w = 24;
      x = 0;
      y = 17;
    };
    panels = [];
  };

  panelRequestRateByHost = mkTimeseries {
    id = 11;
    title = "Request Rate by Host (req/s)";
    description = "Caddy HTTP requests per second broken down by virtual host. Useful for spotting which site is driving load.";
    datasource = promDS;
    gridPos = {
      h = 8;
      w = 24;
      x = 0;
      y = 18;
    };
    unit = "reqps";
    fillOpacity = 20;
    lineWidth = 2;
    targets = [
      (mkPromTarget {
        expr = "sum(rate(caddy_http_requests_total[5m])) by (host)";
        legendFormat = "{{host}}";
        refId = "A";
      })
    ];
  };

  # Latency row

  rowLatency = {
    type = "row";
    id = 20;
    title = "Request Latency";
    collapsed = false;
    gridPos = {
      h = 1;
      w = 24;
      x = 0;
      y = 26;
    };
    panels = [];
  };

  panelRequestDurationHeatmap = {
    type = "heatmap";
    id = 21;
    title = "Request Duration Heatmap (subroute, 5m)";
    description = "Distribution of HTTP request durations from Caddy histogram buckets. Warmer colour = more requests in that latency band.";
    gridPos = {
      h = 10;
      w = 24;
      x = 0;
      y = 27;
    };
    datasource = promDS;
    options = {
      calculate = false;
      cellGap = 2;
      color = {
        exponent = 0.5;
        fill = "dark-orange";
        mode = "scheme";
        reverse = false;
        scale = "exponential";
        scheme = "Oranges";
        steps = 128;
      };
      exemplars = {color = "rgba(255,0,255,0.7)";};
      filterValues = {le = 1.0e-9;};
      legend = {show = false;};
      rowsFrame = {layout = "le";};
      tooltip = {
        mode = "multi";
        showColorScale = false;
        yHistogram = false;
      };
      yAxis = {
        axisPlacement = "left";
        decimals = 0;
        reverse = false;
        unit = "s";
      };
    };
    fieldConfig = {
      defaults = {
        custom = {
          hideFrom = {
            legend = false;
            tooltip = false;
            viz = false;
          };
          scaleDistribution = {
            log = 2;
            type = "log";
          };
        };
      };
      overrides = [];
    };
    targets = [
      (mkPromTarget {
        expr = "sum(increase(caddy_http_request_duration_seconds_bucket{handler=\"subroute\"}[5m])) by (le)";
        legendFormat = "{{le}}";
        refId = "A";
      })
    ];
  };

  # Response codes row

  rowStatusCodes = {
    type = "row";
    id = 30;
    title = "Response Codes";
    collapsed = false;
    gridPos = {
      h = 1;
      w = 24;
      x = 0;
      y = 37;
    };
    panels = [];
  };

  panelStatusCodes = mkTimeseries {
    id = 31;
    title = "Response Status Codes (5m)";
    description = "Hit count per HTTP status code every 5 minutes. Spikes in 4xx/5xx are worth investigating.";
    datasource = lokiDS;
    gridPos = {
      h = 8;
      w = 24;
      x = 0;
      y = 38;
    };
    unit = "short";
    fillOpacity = 10;
    lineWidth = 2;
    targets = [
      (mkLokiTarget {
        expr = ''sum by (status) (count_over_time({job="caddy"} | json | request_host="squirrel.talosvault.net" [5m]))'';
        legendFormat = "{{status}}";
        refId = "A";
      })
    ];
  };

  # Traffic sources row

  rowTrafficSources = {
    type = "row";
    id = 40;
    title = "Traffic Sources";
    collapsed = false;
    gridPos = {
      h = 1;
      w = 24;
      x = 0;
      y = 46;
    };
    panels = [];
  };

  panelTopReferrers = {
    type = "table";
    id = 41;
    title = "Top External Referrers (blog)";
    description = "Which external pages sent visitors to which blog posts over the selected range. Sorted by hit count descending.";
    datasource = lokiDS;
    gridPos = {
      h = 10;
      w = 24;
      x = 0;
      y = 47;
    };
    fieldConfig = {
      defaults = {
        custom = {
          align = "auto";
          cellOptions = {type = "auto";};
          inspect = false;
        };
      };
      overrides = [];
    };
    options = {
      cellHeight = "sm";
      footer = {
        countRows = false;
        fields = "";
        reducer = ["sum"];
        show = false;
      };
      showHeader = true;
    };
    transformations = [
      {
        id = "merge";
        options = {};
      }
      {
        id = "sortBy";
        options = {
          fields = [
            {
              desc = true;
              displayName = "Value";
            }
          ];
        };
      }
    ];
    targets = [
      (mkLokiTarget {
        expr = ''
          sum by (referer, request_uri) (count_over_time(
            {job="caddy"} | json request_headers="request.headers", request_uri="request.uri", request_host="request.host"
            | request_host="squirrel.talosvault.net"
            | request_uri=~"/blog/.*"
            | request_headers =~ `.*Referer.*`
            | regexp `"Referer":\["(?P<referer>[^"]+)"\]`
            | referer !~ `.*squirrel\.talosvault\.net.*`
            [$__range]
          ))'';
        legendFormat = "{{referer}} → {{request_uri}}";
        refId = "A";
        queryType = "instant";
      })
    ];
  };

  # Top URIs row

  rowTopUris = {
    type = "row";
    id = 50;
    title = "Top URIs";
    collapsed = false;
    gridPos = {
      h = 1;
      w = 24;
      x = 0;
      y = 57;
    };
    panels = [];
  };

  panelTopUris = {
    type = "table";
    id = 51;
    title = "Top Requested URIs";
    description = "Most-hit URIs on squirrel.talosvault.net over the selected range, sorted by hit count descending.";
    datasource = lokiDS;
    gridPos = {
      h = 10;
      w = 24;
      x = 0;
      y = 58;
    };
    fieldConfig = {
      defaults = {
        custom = {
          align = "auto";
          cellOptions = {type = "auto";};
          inspect = false;
        };
      };
      overrides = [];
    };
    options = {
      cellHeight = "sm";
      footer = {
        countRows = false;
        fields = "";
        reducer = ["sum"];
        show = false;
      };
      showHeader = true;
    };
    transformations = [
      {
        id = "merge";
        options = {};
      }
      {
        id = "sortBy";
        options = {
          fields = [
            {
              desc = true;
              displayName = "Value";
            }
          ];
        };
      }
    ];
    targets = [
      (mkLokiTarget {
        expr = ''sum by (request_uri) (count_over_time({job="caddy"} | json | request_host="squirrel.talosvault.net" [$__range]))'';
        legendFormat = "{{request_uri}}";
        refId = "A";
        queryType = "instant";
      })
    ];
  };

  # Dashboard assembly

  dashboard = {
    annotations = {
      list = [
        {
          builtIn = 1;
          datasource = {
            type = "grafana";
            uid = "-- Grafana --";
          };
          enable = true;
          hide = true;
          iconColor = "rgba(0, 211, 255, 1)";
          name = "Annotations & Alerts";
          type = "dashboard";
        }
      ];
    };
    description = "Caddy reverse proxy metrics and Loki log analytics for squirrel.talosvault.net.";
    editable = true;
    fiscalYearStartMonth = 0;
    graphTooltip = 1;
    id = null;
    links = [];
    panels = [
      rowBlogTraffic
      panelBlogPageViewsRange
      panelBlogPageViews5m

      rowCaddyTraffic
      panelRequestRateByHost

      rowLatency
      panelRequestDurationHeatmap

      rowStatusCodes
      panelStatusCodes

      rowTrafficSources
      panelTopReferrers

      rowTopUris
      panelTopUris
    ];
    refresh = "30s";
    schemaVersion = 42;
    tags = ["caddy" "nixos" "homelab"];
    templating = {list = [];};
    time = {
      from = "now-6h";
      to = "now";
    };
    timepicker = {
      refresh_intervals = ["10s" "30s" "1m" "5m" "15m" "30m" "1h" "2h" "1d"];
    };
    timezone = "browser";
    title = "Caddy";
    uid = "nixos-caddy";
    version = 1;
  };

  dashboardDir = pkgs.runCommand "grafana-caddy-dashboard" {} ''
    mkdir -p $out
    cp ${pkgs.writeText "caddy.json" (builtins.toJSON dashboard)} $out/caddy.json
  '';
in {
  services.grafana.provision.dashboards.settings.providers = lib.mkAfter [
    {
      name = "Caddy";
      options.path = dashboardDir;
      options.foldersFromFilesStructure = false;
    }
  ];
}
