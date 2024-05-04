{pkgs, ...}: {
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "23.11";
  xdg.enable = true;

  home.packages = with pkgs; [
    unzip
    zip
    file
    nload
    wget
    eza
    ripgrep
    sd
    fd
    jq
    bat
    duf
    ncdu
    htop
    neovim
    psmisc
    usbutils
  ];
}
