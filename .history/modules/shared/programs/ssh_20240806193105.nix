{ config, pkgs, lib, ... }:

let
  user = "ehbr";
in
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    forwardAgent = true;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        "/home/${user}/.ssh/config_external"
      )
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        "/Users/${user}/.ssh/config_external"
      )
    ];
    matchBlocks = lib.mkMerge [
      {
        "github.com" = {
          identitiesOnly = true;
          identityFile = [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
              "/home/${user}/.ssh/id_github"
            )
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
              "/Users/${user}/.ssh/id_github"
            )
          ];
        };
      }
      {
        "ehbr.cloud" = {
          identitiesOnly = true;
          identityFile = [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
              "/home/${user}/.ssh/id_github"
            )
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
              "/Users/${user}/.ssh/id_github"
            )
          ];
        };
      }

      (
        lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
          {
            "gitlab.mobbtech.com" = {
              identitiesOnly = true;
              identityFile = [
                (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
                  "/home/${user}/.ssh/id_work"
                )
                (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
                  "/Users/${user}/.ssh/id_work"
                )
              ];
            };
          }
      )
    ];
  };
}
