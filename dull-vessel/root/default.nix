{pkgs, ...}: {
  imports = [
    ../users-common
  ];

  home.packages = with pkgs; [
    python3
  ];

  home.username = "root";
  home.homeDirectory = "/root";
}
