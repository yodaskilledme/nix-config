# My nvim config https://github.com/MrEhbr/nvim-config
self: super: {
  dev-env = super.writeShellApplication {
    name = "dev_env";
    text = ''
      if [ -z "$1" ]; then
        echo "no template specified"
        exit 1
      fi

      TEMPLATE=$1

      nix \
        --experimental-features 'nix-command flakes' \
        flake init \
        --template \
        "github:MrEhbr/dev-templates#''${TEMPLATE}"
    '';
  };
}
