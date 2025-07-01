{config, ...}: {
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
      gtk-titlebar = false;
      window-padding-x = 5;
      window-padding-y = 3;
      font-family = config.preferences.font.monospace;
      mouse-scroll-multiplier = 3;
      gtk-single-instance = true;
    };
  };
}
