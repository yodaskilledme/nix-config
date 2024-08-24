{ pkgs }:

with pkgs; [
  # General packages for development and system management
  git
  lazygit
  act
  bat
  btop
  jless
  coreutils
  delta
  wget
  ansible
  yai
  just
  yazi

  # Encryption and security tools
  age

  # Cloud-related tools and SDKs
  docker
  docker-compose
  docker-buildx

  # Media-related packages
  ffmpeg
  fd
  glow
  fzf

  # Node.js development tools
  nodePackages.npm # globally install npm
  nodejs

  # Common dev tools
  go
  rustc
  cargo
  php


  # Text and terminal utilities
  just
  htop
  jq
  httpie
  ripgrep
  tree
  eza
  zoxide
  atuin
  unzip

  dev-env # from overlay
]
