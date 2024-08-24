{ config, pkgs, lib, ... }:

let
  user = "yodaskilledme";
  xdg_configHome = "/home/${user}/.config";
  shared-files = import ../shared/files.nix { inherit user config pkgs; };

in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
    file = shared-files // import ./files.nix { inherit user pkgs; };
    stateVersion = "21.05";
    sessionVariables = {
      LC_ALL = "en_US.UTF-8";
      EDITOR = "nvim";
      GOPATH = "$HOME/Go";
      GOBIN = "$HOME/Go/bin";
      BUN_INSTALL = "$HOME/.bun";
      DIRENV_WARN_TIMEOUT = "5m";
      DIRENV_LOG_FORMAT = "";
    };
  };

  # Screen lock
  services = {
    # Auto mount devices
    udiskie.enable = true;
  };

  programs = { gpg.enable = true; };

  imports = import ../shared/home-manager.nix;


}
