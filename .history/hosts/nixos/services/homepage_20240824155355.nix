{ options, config, lib, ... }:

let
  homepagePort = 8082;
  domain = "yodaskilledme.cloud";
in
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = homepagePort;
    environmentFile = config.age.secrets.homepage.path;
    settings = {
      title = "Homepage";
      theme = "dark";
      language = "en";
      headerStyle = "boxedWidgets";
      disableCollape = true;
      cardBlur = "md";
      color = "gray";
      fiveColumns = true;
      statusStyle = "dot";
      hideVersion = true;
      layout = [
        {
          "Networking" = {
            style = "row";
            columns = 1;
          };
        }
        {
          "Media" = {
            style = "row";
            columns = 3;
          };
        }
        {
          "Downloaders" = {
            style = "row";
            columns = 1;
          };
        }
        {
          "Monitoring" = {
            style = "row";
            columns = 2;
          };
        }
        {
          "Misc" = {
            style = "row";
            columns = 1;
          };
        }
      ];
    };
    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/mnt/storage";
          cputemp = true;
          uptime = true;
        };
      }
    ];
    services = [
      {
        "Networking" = [
          {
            AdGuard = {
              icon = "adguard-home";
              href = "https://adguard.${domain}";
              description = "DNS-level Ad Blocking";
              widget = {
                type = "adguard";
                url = "https://adguard.${domain}";
              };
            };
          }
        ];
      }
      {
        "Monitoring" = [
          {
            Grafana = {
              icon = "grafana";
              href = "https://grafana.${domain}";
              description = "Monitoring";
            };
          }
          {
            Prometheus = {
              icon = "prometheus";
              href = "https://prometheus.${domain}";
              description = "Monitoring";
              widget = {
                type = "prometheus";
                url = "https://prometheus.${domain}";
              };
            };
          }
          {
            "Uptime Kuma" = {
              icon = "uptime-kuma";
              href = "https://uptime.${domain}";
              description = "Uptime monitor";
              widget = {
                type = "uptimekuma";
                url = "https://uptime.${domain}";
                slug = "default";
              };
            };
          }
        ];
      }
      {
        "Downloaders" = [
          {
            Transmission = {
              icon = "transmission";
              href = "https://transmission.${domain}";
              description = "Torrent client";
              widget = {
                type = "transmission";
                url = "https://transmission.${domain}";
              };
            };
          }
          {
            Aria2 = {
              icon = "ariang";
              href = "https://downloads.${domain}";
              description = "Download manager";
            };
          }
        ];
      }
      {
        "Media" = [
          {
            Jellyfin = {
              icon = "jellyfin";
              href = "https://jellyfin.${domain}";
              description = "Media server";
              widget = {
                type = "jellyfin";
                url = "https://jellyfin.${domain}";
                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                enableBlocks = true;
                enableNowPlaying = false;
              };
            };
          }
          {
            Sonarr = {
              icon = "sonarr";
              href = "https://sonarr.${domain}";
              description = "TV Shows";
              widget = {
                type = "sonarr";
                url = "https://sonarr.${domain}";
                key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
                enableBlocks = true;
                showEpisodeNumber = true;
              };
            };
          }
          {
            Radarr = {
              icon = "radarr";
              href = "https://radarr.${domain}";
              description = "Movies";
              widget = {
                type = "radarr";
                url = "https://radarr.${domain}";
                key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
                enableBlocks = true;
                showEpisodeNumber = true;
              };
            };
          }
        ];
      }
      {
        "Misc" = [
          {
            ntfy = {
              icon = "ntfy";
              href = "https://ntfy.${domain}";
              description = "Notifications";
            };
          }
          {
            "Homebridge" = {
              icon = "homebridge";
              href = "https://homebridge.${domain}";
              description = "HomeKit";
            };
          }
        ];
      }
    ];
  };

  environment.systemPackages = [ config.services.homepage-dashboard.package ];
}
