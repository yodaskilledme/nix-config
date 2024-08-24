{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
          sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
        };
      }
      {
        name = "plugin-git";
        src = pkgs.fetchFromGitHub {
          owner = "jhillyerd";
          repo = "plugin-git";
          rev = "c2b38f53f0b04bc67f9a0fa3d583bafb3f558718";
          sha256 = "sha256-efKPbsXxjHm1wVWPJCV8teG4DgZN5dshEzX8PWuhKo4=";
        };
      }
    ];
    shellAliases = {
      grep = "grep --color=auto";
      groot = "cd (git rev-parse --show-cdup)";
      rg = "rg -p --glob '!node_modules/*' --color=auto";
      shell = "nix-shell -p";
    };

    shellInit = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
      source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    '';
    interactiveShellInit = ''
      set fish_greeting
      set -gx HISTORY_IGNORE "pwd:ls:cd:z:clear"

      fish_add_path -g /usr/local/bin
      fish_add_path -g $HOME/bin
      fish_add_path -g $HOME/.cargo/bin
      fish_add_path -g $GOBIN
      fish_add_path -g $BUN_INSTALL/bin

      if type -q bat
        alias cat "bat --style=plain --paging=never"
      end
      if type -q tmux
        if not set -q TMUX
          set -g TMUX tmux new-session -d -s base
          eval $TMUX
          tmux attach-session -d -t base
        end
      end
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish | source

      # Kanagawa Fish shell theme
      # A template was taken and modified from Tokyonight:
      # https://github.com/folke/tokyonight.nvim/blob/main/extras/fish_tokyonight_night.fish
      set -l foreground DCD7BA normal
      set -l selection 2D4F67 brcyan
      set -l comment 727169 brblack
      set -l red C34043 red
      set -l orange FF9E64 brred
      set -l yellow C0A36E yellow
      set -l green 76946A green
      set -l purple 957FB8 magenta
      set -l cyan 7AA89F cyan
      set -l pink D27E99 brmagenta

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment
    '';
  };

  programs.starship = {
    enable = true;

    enableFishIntegration = true;

    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$nix_shell"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$line_break"
        "$character"
      ];
      right_format = "$cmd_duration $status";

      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      status = {
        disabled = false;
        format = "[$symbol $status]($style)";
        symbol = "✗";
        map_symbol = true;
      };

      directory = { style = "blue"; };
      nix_shell = {
        style = "bold blue";
        symbol = "nix ";
        format = "via [$symbol]($style)";
      };
      git_branch = {
        format = "[$branch ]($style)";
        style = "bright-black";
      };
      git_state = {
        format = "([$state( $progress_current/$progress_total)]($style)) ";
        style = "bright-black";
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    extraOptions = [ "--group-directories-first" "-g" ];
    icons = true;
    git = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      declare -A direnv_layout_dirs
        direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
          echo -n "${config.xdg.cacheHome}"/direnv/layouts/
          echo -n "$PWD" | shasum | cut -d ' ' -f 1
        )}"
      }
    '';
  };

  programs.bat = {
    enable = true;
    themes = {
    kanagawa = {
        src = pkgs.fetchFromGitHub {
          owner = "rebelot";
          repo = "kanagawa.nvim";
          rev = "7b411f9e66c6f4f6bd9771f3e5affdc468bcbbd2";
          sha256 = "sha256-kV+hNZ9tgC8bQi4pbVWRcNyQib0+seQrrFnsg7UMdBE=";
        };
        file = "/extras/kanagawa.tmTheme";
      };
    };

    config = {
      theme = "kanagawa";
      pager = "less -FR";
    };
  };
}
