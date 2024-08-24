{ options, config, lib, pkgs, ... }:
{
  services.uptime-kuma = {
    enable = true;
    settings.HOST = "127.0.0.1";
    settings.PORT = "4000";
    settings.DATA_DIR = "/var/lib/uptime-kuma/";
  };

  services.restic.backups.homelab.paths = [ "/var/lib/uptime-kuma" ];
}
