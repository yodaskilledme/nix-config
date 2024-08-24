_: {

  imports = [
    ./services/homepage.nix
    ./services/adguard.nix
    ./services/nginx.nix
    ./services/media.nix
    ./services/prometheus.nix
    ./services/grafana
    ./services/uptime-kuma.nix
    ./services/fail2ban.nix
    ./services/ntfy.nix
    ./services/tailscale.nix
    ./services/restic.nix
    ./services/homebridge.nix
  ];
}
