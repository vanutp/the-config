{...}: {
  # Never change this
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
  xdg.enable = true;

  programs.direnv = {
    enable = true;
    silent = true;
  };
}
