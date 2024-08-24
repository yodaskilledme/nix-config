{ pkgs, ... }:
let
  domain = "ehbr.cloud";
in
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://prometheus.${domain}";
    enableReload = true;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "127.0.0.1:9100" ];
        }];
      }
      {
        job_name = "systemd";
        static_configs = [{
          targets = [ "127.0.0.1:9558" ];
        }];
      }
      {
        job_name = "smartctl";
        static_configs = [{
          targets = [ "127.0.0.1:9633" ];
        }];
      }
      {
        job_name = "nginx";
        static_configs = [{
          targets = [ "127.0.0.1:9113" ];
        }];
      }
      {
        job_name = "ntfy";
        static_configs = [{
          targets = [ "127.0.0.1:19095" ];
        }];
      }
      {
        job_name = "adguard";
        static_configs = [{
          targets = [ "127.0.0.1:9617" ];
        }];
      }
      {
        job_name = "process-exporter";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [ "localhost:9256" ];
          }
        ];
      }
      {
        job_name = "speedtest";
        scrape_timeout = "30s";
        scrape_interval = "1h";
        static_configs = [{
          targets = [ "127.0.0.1:9862" ];
        }];
      }
    ];
    exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [ "systemd" ];
        # extraFlags = [ "--collector.textfile.directory=/etc/nix" ];
      };

      process = {
        enable = true;
        port = 9256;
        user = "root";
        settings.process_names = [
          {
            name = "{{ .Matches.Wrapped }}";
            cmdline = [ "^/nix/store[^ ]*/(?P<Wrapped>[^ /]*)" ];
          }
          {
            name = "{{ .Matches.Command }}";
            cmdline = [ "(?P<Command>[^ ]+)" ];
          }
        ];
      };

      systemd = {
        enable = true;
        port = 9558;
      };

      statsd = {
        enable = true;
        port = 9102;
      };

      smartctl = {
        enable = true;
        user = "root";
        port = 9633;
      };

      nginx = {
        enable = true;
        port = 9113;
        openFirewall = false;
      };
    };
  };

  systemd.services = {
    "adguard-exporter" = {
      enable = true;
      description = "AdGuard metric exporter for Prometheus";
      documentation = [ "https://github.com/totoroot/adguard-exporter/blob/master/README.md" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.adguard-exporter}/bin/adguard-exporter -adguard_hostname 127.0.0.1 -adguard_port 3000 -log_limit 10000";
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        User = "root";
        Group = "root";
      };
    };
    "speedtest-exporter" = {
      enable = true;
      description = "Speedtest Prometheus Exporter exposing results from speedtest.net";
      documentation = [ "https://github.com/danopstech/speedtest_exporter/blob/main/README.md" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.speedtest_exporter}/bin/speedtest_exporter -port 9862"; # -server_id 15152";
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        User = "root";
        Group = "root";
      };
    };
  };

}
