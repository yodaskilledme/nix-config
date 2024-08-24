{ config, pkgs, lib, home-manager, ... }:

let
  user = "yodaskilledme";
  sharedFiles = import ../shared/files.nix { inherit user config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
    ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.fish;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      # cleanup = "zap";
    };


    casks = pkgs.callPackage ./casks.nix { };

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "1Password for Safari" = 1569813296;
      Things = 904280696;
      Hush = 1544743900;
      Dato = 1470584107;
    };
  };
  environment.shellInit = ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.${user} = { pkgs, config, lib, ... }: {
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix { };
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];

        sessionVariables = {
          LC_ALL = "en_US.UTF-8";
          EDITOR = "nvim";
          GOPATH = "$HOME/Go";
          GOBIN = "$HOME/Go/bin";
          BUN_INSTALL = "$HOME/.bun";
          DIRENV_WARN_TIMEOUT = "5m";
          DIRENV_LOG_FORMAT = "";
        };

        stateVersion = "23.11";
      };
      imports = [ ./programs/alacritty.nix ./programs/tmux.nix ] ++ import ../shared/home-manager.nix;

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock = {
      enable = true;
      entries = [
        { path = "/System/Applications/Mail.app/"; }
        { path = "/System/Applications/Calendar.app/"; }
        { path = "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/"; }
        { path = "/System/Applications/Music.app/"; }
        { path = "/Applications/Obsidian.app/"; }
        { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
        { path = "/Applications/Telegram.app/"; }
        { path = "/Applications/Slack.app/"; }
        { path = "/System/Applications/System Settings.app/"; }
      ];
    };
  };
}
