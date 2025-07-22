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
    dua
    htop
    psmisc
    pciutils
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
