{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    ./editor.nix
    ./banner
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
    lsd = {
      enable = true;
      icons = {
        filetype = {
          dir = "";
        };
        name = {
          videos = "󱧺";
          desktop = "󱋣";
          documents = "󰲂";
          public = "󱞊";
          home = "󱂵";
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
        {
          name = "zsh-powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
          file = "powerlevel10k.zsh-theme";
        }
        {
          name = "p10k-prompt";
          src = "${
            pkgs.writeTextDir "share/zsh-powerlevel10k-prompt/prompt.zsh" (builtins.readFile ./prompt.zsh)
          }/share/zsh-powerlevel10k-prompt";
          file = "prompt.zsh";
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
