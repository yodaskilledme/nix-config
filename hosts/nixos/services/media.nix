{ config, pkgs, lib, ... }:
let
  user = "media";
  group = "storage";
  mediaDir = "/media";
in
{
  # Create the directories that the services will need with the correct permissions
  systemd.tmpfiles.rules = [
    "L /mnt/storage/media - - - - ${mediaDir}"
    "d ${mediaDir}/library/Movies 2775 ${user} ${group} -"
    "d ${mediaDir}/library/Shows 2775 ${user} ${group} -"
    "d ${mediaDir}/library/Doramas 2775 ${user} ${group} -"
    "d ${mediaDir}/library/Anime 2775 ${user} ${group} -"
    "d ${mediaDir}/library/AnimeMovies 2775 ${user} ${group} -"
    "d ${mediaDir}/torrents 2775 ${user} ${group} -"
    "d ${mediaDir}/torrents/.incomplete 2775 ${user} ${group} -"
    "d ${mediaDir}/services/radarr 2775 ${user} ${group} -"
    "d ${mediaDir}/services/sonarr 2775 ${user} ${group} -"
    "d ${mediaDir}/services/jellyfin 2775 ${user} ${group} -"
    "d ${mediaDir}/services/jellyfin/data 2775 ${user} ${group} -"
    "d ${mediaDir}/services/jellyfin/log 2775 ${user} ${group} -"
    "d ${mediaDir}/services/jellyfin/cache 2775 ${user} ${group} -"
  ];

  users.users =
    {
      ${user} = {
        isSystemUser = true;
        group = "${group}";
      };
    };

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    downloadDirPermissions = "0770";
    openPeerPorts = true;
    user = user;
    group = group;
    settings = {
      incomplete-dir-enabled = true;
      download-dir = "${mediaDir}/torrents";
      incomplete-dir = "${mediaDir}/torrents/.incomplete";
      watch-dir-enabled = false;
      rpc-whitelist = "127.0.0.1,192.168.*.*";
      rpc-host-whitelist = "*";
      rpc-host-whitelist-enabled = true;
      ratio-limit = 0;
      ratio-limit-enabled = true;
      download-queue-enabled = false;
      seed-queue-enabled = false;
      utp-enabled = true;
      # NOTE: This mask needs to be specified in base 10 instead of octal.
      umask = 7; # 0o007 == 7
      cache-size-mb = 1024;
      peer-limit-per-torrent = 250;
      peer-limit-global = 10000;
    };
  };

  # TODO: Override for this issue:
  # https://github.com/NixOs/nixpkgs/issues/258793
  # As of 2024-07-18, still not fixed, despite that issue being closed.
  systemd.services.transmission.serviceConfig = {
    RootDirectoryStartOnly = lib.mkForce false;
    RootDirectory = lib.mkForce "";
  };
  # Always prioritize other services wrt. I/O
  systemd.services.transmission.serviceConfig.IOSchedulingPriority = 7;

  systemd.services.aria2 = {
    description = "aria2 Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart =
      let
        path = "/var/lib/aria2";
        settings = {
          dir = "${mediaDir}/torrents";
          disk-cache = "64M";
          file-allocation = "none";
          no-file-allocation-limit = "64M";
          continue = true;
          always-resume = false;
          max-resume-failure-tries = 0;
          remote-time = true;
          input-file = "aria2.session";
          save-session = "aria2.session";
          save-session-interval = 1;
          http-accept-gzip = true;
          content-disposition-default-utf8 = true;
          enable-rpc = true;
          rpc-listen-all = true;
          rpc-allow-origin-all = true;
          rpc-secure = false;
          check-certificate = false;
        };
        conf = lib.generators.toKeyValue { } settings;
      in
      ''
        if [[ ! -e "${path}/${settings.save-session}" ]]
        then
          touch "${path}/${settings.save-session}"
        fi
        echo "${conf}" > aria2.conf
      '';
    serviceConfig = {
      User = user;
      Group = group;
      StateDirectory = "aria2";
      RuntimeDirectory = "aria2";
      WorkingDirectory = "/var/lib/aria2";
      ExecStart = ''
        ${pkgs.aria2}/bin/aria2c --conf-path=/var/lib/aria2/aria2.conf
      '';
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "on-abort";
    };
  };

  services.prowlarr = {
    enable = true;
  };

  services.radarr = {
    enable = true;
    user = user;
    group = group;
    dataDir = "${mediaDir}/services/radarr";
  };

  services.sonarr = {
    enable = true;
    user = user;
    group = group;
    dataDir = "${mediaDir}/services/sonarr";
  };

  services.jellyfin = {
    enable = true;
    user = user;
    group = group;
    dataDir = "${mediaDir}/services/jellyfin/data";
    logDir = "${mediaDir}/services/jellyfin/log";
    configDir = "${mediaDir}/services/jellyfin";
    cacheDir = "${mediaDir}/services/jellyfin/cache";
  };

  services.restic.backups.homelab.paths = [
    "/var/lib/prowlarr"
    config.services.jellyfin.dataDir
    config.services.jellyfin.configDir
    config.services.sonarr.dataDir
    config.services.radarr.dataDir
  ];
}
