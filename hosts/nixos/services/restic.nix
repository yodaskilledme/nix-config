{ pkgs
, config
, ...
}: {
  services.restic.backups = {
    homelab = {
      repository = "rclone:google_drive:backups";
      passwordFile = config.age.secrets."restic".path;
      rcloneConfigFile = config.age.secrets."rclone".path;
      pruneOpts = [
        "--keep-daily 7"
      ];
      initialize = true;
      timerConfig.OnCalendar = "*-*-* *:00:00";
      timerConfig.RandomizedDelaySec = "5m";
      extraBackupArgs = [
        "--exclude=\".direnv\""
        "--exclude=\".terraform\""
        "--exclude=\"node_modules/*\""
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    restic
    rclone
  ];
}
