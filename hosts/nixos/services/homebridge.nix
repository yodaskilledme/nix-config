{ config
, lib
, pkgs
, ...
}: {
  virtualisation.oci-containers = {
    containers = {
      "homebridge" = {
        image = "ghcr.io/homebridge/homebridge";
        volumes = [
          "/var/lib/homebridge:/homebridge:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network=host"
        ];
      };
    };
  };

  services.restic.backups.homelab.paths = [ "/var/lib/homebridge" ];

  networking.firewall.allowedTCPPorts = [ 51317 ];
}
