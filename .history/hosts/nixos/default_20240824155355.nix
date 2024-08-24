{ config, lib, inputs, pkgs, agenix, ... }:

let
  user = "yodaskilledme";
  keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxk1quGRSKZkYR6tLHTFTLUJ+nyu+037Vzbjj7ZCZIq mr.yodaskilledme@gmail.com" ];
in
{
  imports = [
    ../../modules/nixos/secrets.nix
    ../../modules/nixos/disk-config.nix
    ../../modules/shared
    ../../modules/shared/cachix
    agenix.nixosModules.default
    ./services.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 42;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
    kernelModules = [ "uinput" "kvm-intel" "v4l2loopback" ];
    extraModulePackages = [ pkgs.linuxPackages_latest.v4l2loopback ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Set your time zone.
  time.timeZone = "Europe/Nicosia";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = "server"; # Define your hostname.
    networkmanager.enable = false;
    interfaces.enp2s0 = {
      wakeOnLan.enable = true;
      macAddress = "d1:7f:c9:27:cc:d8";
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.2.3";
          prefixLength = 24;
        }
      ];
      ipv4.routes = [
        {
          address = "0.0.0.0";
          prefixLength = 0;
          via = "192.168.2.1";
          options = {
            metric = "100";
          };
        }
      ];
    };

    interfaces.wlp3s0 = {
      useDHCP = false;
      macAddress = "b7:4b:57:19:4f:f3";
      ipv4.addresses = [
        {
          address = "192.168.2.31";
          prefixLength = 24;
        }
      ];
      ipv4.routes = [
        {
          address = "0.0.0.0";
          prefixLength = 0;
          via = "192.168.2.1";
          options = {
            metric = "200";
          };
        }
      ];
    };

    defaultGateway = {
      address = "192.168.2.1";
      interface = "enp2s0";
    };

    wireless = {
      enable = true;
      environmentFile = config.age.secrets.wifi.path;
      networks = {
        "IoT" = {
          psk = "@PKS_IOT@";
        };
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 5001 5201 ];
      allowedUDPPorts = [ 5001 5201 ];
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.tcp_timestamps" = 1; # Enable TCP timestamps
    "net.ipv4.tcp_sack" = 1; # Enable TCP Selective Acknowledgment (SACK)
    "net.ipv4.ip_forward" = 1; # Enable IP forwarding
    "net.core.netdev_max_backlog" = 2500; # Increase the maximum number of packets in the queue
    "net.core.rmem_max" = 16777216; # Increase the maximum receive socket buffer size
    "net.core.wmem_max" = 16777216; # Increase the maximum send socket buffer size
    "net.core.somaxconn" = 1024; # Increase the maximum number of incoming connections
    "net.ipv4.tcp_max_syn_backlog" = 2048; # Increase the maximum number of SYN backlog
    "net.ipv4.tcp_rmem" = "4096 87380 16777216"; # Set TCP receive buffer sizes
    "net.ipv4.tcp_wmem" = "4096 65536 16777216"; # Set TCP send buffer sizes
    "net.core.optmem_max" = 2048000; # Increase the maximum ancillary buffer size
    "vm.swappiness" = 10; # Adjust based on your system's RAM and workload
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
  };
  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
    DefaultLimitNOFILESoft=1048576
    DefaultLimitNPROC=1048576
    DefaultLimitNPROCSoft=1048576
    DefaultLimitFSIZE=infinity
    DefaultLimitFSIZESoft=infinity
  '';

  # Turn on flag for proprietary software
  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings.allowed-users = [ "${user}" ];
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Manages keys and such
  programs = {
    gnupg.agent.enable = true;
    fish.enable = true;
  };

  services = {
    # Let's be able to SSH into this machine
    openssh.enable = true;

    gvfs.enable = true; # Mount, trash, and other functionalities
  };

  hardware = {
    graphics.enable = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu = {
      intel = {
        updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
  };


  # Add docker daemon
  virtualisation.docker.enable = true;
  virtualisation.docker.logDriver = "json-file";

  users.groups.storage = {
    gid = 3000;
  };

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "docker"
        "storage"
      ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
      shell = pkgs.fish;
    };
  };

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      # nerdfonts
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "JetBrainsMono"
        ];
      })
    ];
  };

  environment.systemPackages = with pkgs; [
    agenix.packages."${pkgs.system}".default # "x86_64-linux"
    gitAndTools.gitFull
    inetutils
  ];

  system.stateVersion = "21.05"; # Don't change this
}
