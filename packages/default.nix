{pkgs, ...}: {
  imports = [
    ./_64gram
    ./split-monitor-workspaces
    ./veyon
    ./vhap
  ];

  packages = {
    hyprland = pkgs.hyprland;
    xdg-desktop-portal-hyprland = pkgs.xdg-desktop-portal-hyprland;
  };
}
