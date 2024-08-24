{ options, config, lib, ... }:

let
  domain = "ehbr.cloud";
  ntfyPort = 6780;
  ntfyMetricsPort = 19095;
  ntfyHost = "ntfy.${domain}";
in
{
  services.ntfy-sh = {
    enable = true;
    group = "ntfy";
    user = "ntfy";
    settings = {
      base-url = "https://${ntfyHost}";
      listen-http = ":${toString ntfyPort}";
      behind-proxy = true;
      auth-default-access = "deny-all";
      upstream-base-url = "https://ntfy.sh";
      # Set to "disable" to disable web UI
      # See https://github.com/binwiederhier/ntfy/issues/459
      web-root = "app";
      # Enable metrics endpoint for Prometheus
      enable-metrics = true;
      metrics-listen-http = ":${toString ntfyMetricsPort}";
    };
  };

  users = {
    groups."ntfy" = { };
    users."ntfy" = {
      name = "ntfy";
      group = "ntfy";
      isSystemUser = true;
    };
  };

  environment.systemPackages = [ config.services.ntfy-sh.package ];

  services.restic.backups.homelab.paths = [ "/var/lib/ntfy-sh/user.db" "/var/lib/ntfy-sh/attachments" "/var/lib/ntfy-sh/cache-file.db" ];
}
