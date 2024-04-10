{pkgs, ...}: {
  home.packages = with pkgs; [
    python3
  ];

  home.username = "root";
  home.homeDirectory = "/root";
}
