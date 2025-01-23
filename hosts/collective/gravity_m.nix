{pkgs, ...}: {
  home.packages = with pkgs; [
    micro
    nano
  ];

  home.username = "gravity_m";
  home.homeDirectory = "/home/gravity_m";
}
