{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  tmux
  reattach-to-user-namespace
  alacritty
  dockutil
  pam-reattach
  im-select # from overlay
  darwin.libiconv
  glab
  gh
]
