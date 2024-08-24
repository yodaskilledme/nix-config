{ user, config, pkgs, ... }:

let
  # xdg_configHome = "${config.users.users.${user}.home}/.config";
  # xdg_dataHome = "${config.users.users.${user}.home}/.local/share";
  # xdg_stateHome = "${config.users.users.${user}.home}/.local/state";
  workPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINir82tbmO1CXh0cTT1/tsXjt3WLJcKFhxbCJi22Rdha yodaskilledme@gmail.com";
in
{
  ".ssh/id_work.pub" = {
    text = workPublicKey;
  };
}
