{pkgs, ...}: {
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    unzip
    file
    nload
    wget
    eza
    ripgrep
    sd
    fd
    bat
    duf
    ncdu
    htop
    neovim
    psmisc
  ];
}
