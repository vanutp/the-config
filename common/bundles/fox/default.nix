{pkgs, ...}: {
  imports = [
    ./shell
    ./dev.nix
  ];

  home.packages = with pkgs; [
    age
    ssh-to-age
    sops

    dive
    nix-tree
    fastfetch
    whois
  ];

  home.username = "fox";
  home.homeDirectory = "/home/fox";
}
