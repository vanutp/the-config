{pkgs, ...}: {
  imports = [
    ./server.nix
  ];

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
    neovim
    pgcli

    age
    ssh-to-age
    sops

    dive
    nix-tree
    fastfetch
    whois
    rdap
  ];
}
