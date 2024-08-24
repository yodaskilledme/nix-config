{ pkgs, options, config, lib, ... }:
{
  services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      authKeyFile = config.age.secrets."tailscale".path;
      extraUpFlags = [
        "--accept-dns=false"
        "--advertise-routes=192.168.0.0/24"
        "--advertise-exit-node"
      ];
    };
  };

  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

}
