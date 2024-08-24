{ user, pkgs, config, ... }:

let
  personalPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxk1quGRSKZkYR6tLHTFTLUJ+nyu+037Vzbjj7ZCZIq yodaskilledme@gmail.com";
  home = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";

in
{
  ".ssh/id_github.pub" = {
    text = personalPublicKey;
  };
}
