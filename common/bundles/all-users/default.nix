{
  pkgs,
  common,
  ...
}: {
  imports = [
    (common.blocks.nix-settings true)
  ];
  programs.home-manager.enable = true;
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
    psmisc
    usbutils
    git
  ];
}
