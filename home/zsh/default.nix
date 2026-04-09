{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    ./micro.nix
    ./rizzlefetch
  ];
  home = {
    packages = with pkgs; [
      grc
      fzf
      lsd
      fd
      git
      gh
    ];
    sessionVariables = {
      EDITOR = "micro";
      GOPATH = "$HOME/.local/share/go";
    };
  };
  programs = {
    nix-index = {
      enable = true;
      enableZshIntegration = false; # slow - just use comma
    };
    nix-index-database.comma.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };
    lsd.enable = true;
    starship = {
      enable = true;
      enableZshIntegration = true;
      presets = ["no-runtime-versions"];
      settings = {
        add_newline = false;
        format = lib.strings.concatStrings [
          "($username"
          "(@$hostname) )"
          "\${custom.directory_icon}"
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_status"
          "$direnv"
          "$env_var"
          "$jobs"
          "$shlvl"
          "$character"
        ];
        # line_break.disabled = true;
        git_branch = {
          format = "[($symbol$branch(:$remote_branch) )]($style)";
          symbol = "󰊢 ";
          style = "yellow";
        };
        git_status = {
          format = "[($all_status$ahead_behind)]($style)";
          style = "yellow";
          conflicted = "$count󰩋 ";
          ahead = "$count󰶣 ";
          behind = "$count󰶡 ";
          diverged = "$ahead_count󰶣 $behind_count󰶡 ";
          up_to_date = "";
          untracked = "$count󰱼 ";
          stashed = "$count󱋡 ";
          modified = "$count󱇧 ";
          staged = "$count󰈖 ";
          renamed = "$count󱈖 ";
          deleted = "$count󱪡 ";
        };
        direnv = {
          disabled = false;
          format = "[($loaded)]($style)";
          loaded_msg = "󱧶 ";
          unloaded_msg = "󱧴 ";
          style = "bright-purple";
        };
        directory = {
          format = "[$read_only]($read_only_style)[$path]($style) ";
          truncate_to_repo = false;
          truncation_symbol = "…";
          truncation_length = 3;
          style = "bold blue";
          read_only = "󰏮 ";
          read_only_style = "bold blue";
        };
        username = {
          format = "([ $user]($style))";
          style_root = "bright-red";
        };
        hostname = {
          format = "[($hostname)]($style)";
        };
        custom = {
          directory_icon = {
            when = true;
            style = "blue";
            command = "lsd -d $(pwd) --icon always | cut -c1-4";
            format = "[$symbol($output )]($style)";
          };
        };
        shlvl = {
          disabled = false;
          symbol = "❯";
          style = "bright-green";
          repeat = true;
          repeat_offset = 1;
          format = "[$symbol]($style)";
        };
        character = {
          success_symbol = "[❯](bold bright-green)";
          error_symbol = "[❯](bold bright-red)";
        };
      };
    };
    zsh = {
      enable = true;
      plugins = [
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
        {
          name = "grc";
          src = "${pkgs.grc}/etc";
          file = "grc.zsh";
        }
      ];
      shellAliases = {
        edit = "$EDITOR";
        open = "xdg-open";
        l = "lsd --almost-all --long --git --group-dirs first --no-symlink --date relative";
        ls = lib.mkForce "lsd --group-dirs first";
        lt = lib.mkForce "lsd --tree --long --git --group-dirs first --no-symlink --date relative";
        ssh = "TERM='xterm-256color' ssh";
        cd = "z";
      };
      sessionVariables = {
        GREP_OPTIONS = "--color=auto";
        DIRENV_WARN_TIMEOUT = 0;
      };
      dotDir = "${config.xdg.dataHome}/zsh";
      historySubstringSearch.enable = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      initContent = ''
        [[ -o interactive ]] && [[ -n $DISPLAY ]] && [[ $SHLVL -eq 1 ]] && rizzlefetch && echo
        echo

        # keybindings
        bindkey "$terminfo[kcuu1]" history-substring-search-up
        bindkey "$terminfo[kcud1]" history-substring-search-down
        bindkey  "^[[H"   beginning-of-line
        bindkey  "^[[F"   end-of-line
        bindkey  "^[[3~"  delete-char
      '';
    };
  };
}
