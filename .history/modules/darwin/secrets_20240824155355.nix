{ config, pkgs, agenix, secrets, ... }:

let user = "yodaskilledme"; in
{
  age = {
    identityPaths = [
      "/Users/${user}/.ssh/id_ed25519"
    ];

    secrets = {
      "github-ssh-key" = {
        symlink = true;
        path = "/Users/${user}/.ssh/id_github";
        file = "${secrets}/github-ssh-key.age";
        mode = "600";
        owner = "${user}";
        group = "staff";
      };
      "work-ssh-key" = {
        symlink = true;
        path = "/Users/${user}/.ssh/id_work";
        file = "${secrets}/work-ssh-key.age";
        mode = "600";
        owner = "${user}";
        group = "staff";
      };

    };
  };
}
