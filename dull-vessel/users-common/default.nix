{pkgs, ...}: {
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    ventoy-full

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
