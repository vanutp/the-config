{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./server.nix
  ];

  options = with lib; {
    programs.zsh.initExtraHost = mkOption {
      type = types.str;
      description = "Per-host zsh init script";
      default = "";
    };
  };

  config = {
    home.packages = with pkgs; [
      peco
    ];

    home.sessionPath = [
      "$HOME/.local/bin"
    ];
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "$EDITOR";
      TERM = "xterm-256color";
    };

    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";

      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autocd = true;

      shellAliases = let
        eza = lib.getExe pkgs.eza;
      in {
        pgcli = "PAGER='less -S' pgcli";
        e = "$EDITOR";
        se = "sudoedit";
        ls = "${eza} --group-directories-first -ag --icons always";
        l = "ls -l";
        sls = "sudo ${eza} -ag --icons always";
        sla = "sudo ${eza} -lag --icons always";
        ipy = "ipython";
        copy = "clipcopy";
        open = "xdg-open";
        gst = "git status";
        glg = "git log --stat";
        gcl = "git clone";
        dco = "docker compose";
        sdco = "sudo docker compose";
      };
      shellGlobalAliases = {
        "..." = "../..";
        "...." = "../../..";
        "....." = "../../../..";
        "......" = "../../../../..";
      };
      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
        extended = true;
      };

      initExtraFirst = ''
      '';
      initExtra = lib.mkMerge [
        (lib.mkAfter ''
          # Override value set by kitty integration
          export TERM=xterm-256color
        '')
        ''
          zstyle ':completion:*' rehash true
          function sudoedit() {
            SUDO_COMMAND="sudoedit $@" command sudoedit "$@"
          }
          function take() {
            mkdir -p $@ && cd ''${@:$#}
          }
          function root() {
            readlink $(which $1) | cut -d/ -f1-4
          }
          function __clear-scrollback-buffer {
            clear
            zle .reset-prompt
          }
          zle -N __clear-scrollback-buffer
          bindkey '^L' __clear-scrollback-buffer
        ''
        # TODO: remove
        config.programs.zsh.initExtraHost
      ];

      plugins =
        [
          {
            name = "omz-urlfunctions";
            src = ./omz-urlfunctions;
            file = "omz-urlfunctions.zsh";
          }
        ]
        ++ (builtins.map (name: {
          name = "omz-lib-${name}";
          src = pkgs.oh-my-zsh;
          file = "share/oh-my-zsh/lib/${name}.zsh";
        }) ["clipboard" "compfix" "completion" "history" "key-bindings" "termsupport"])
        ++ [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            src = ./p10k;
            file = "p10k.zsh";
          }
          {
            name = "sudo";
            src = pkgs.oh-my-zsh;
            file = "share/oh-my-zsh/plugins/sudo/sudo.plugin.zsh";
          }
          {
            name = "zsh-peco-history";
            src = pkgs.fetchFromGitHub {
              owner = "jimeh";
              repo = "zsh-peco-history";
              rev = "73615968d46cf172931946b00f89a59da0c124a5";
              hash = "sha256-lEgisjuLrnetIUG0fXl9vH3/ZHgpyQviy7rJazCkMTs=";
            };
          }
        ];
    };
  };
}
