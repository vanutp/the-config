{pkgs, ...}: {
  home.packages = with pkgs; [
    python3
    neovim
  ];

  home.username = "root";
  home.homeDirectory = "/root";
}
