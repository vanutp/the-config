{
  config,
  lib,
  pkgs,
  ...
}: {
  options.setup = let
    inherit (lib) mkOption types;
  in {
    enableTmuxAtLogin = mkOption {
      type = types.bool;
      default = config.setup.isServer;
    };
  };
  config = lib.mkMerge [
    {
      programs.tmux = {
        enable = true;
        plugins = with pkgs; [
          {
            plugin = tmuxPlugins.power-theme;
            extraConfig = "set -g @tmux_power_theme 'violet'";
          }
        ];
        prefix = "`";
        historyLimit = 10000;
        terminal = "tmux-256color";
        mouse = true;
        newSession = true;
        clock24 = true;
      };
    }
    (lib.mkIf config.setup.enableTmuxAtLogin {
      programs.zsh = {
        initContent = lib.mkBefore ''
          if [ ! "$TMUX" ]; then
            tmux attach
            exit
          fi
        '';
      };
    })
  ];
}
