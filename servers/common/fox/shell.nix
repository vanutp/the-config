{pkgs, ...}: {
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

  programs.zsh = {
    initExtraFirst = ''
      if [ ! "$TMUX" ]; then
        tmux attach
        exit
      fi
    '';
  };
}
