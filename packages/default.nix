{pkgs, ...}: {
  imports = [
    ./_64gram
    ./cups-kyodialog
    ./split-monitor-workspaces
    ./veyon
    ./vhap
  ];

  packages = {
    hyprland = pkgs.hyprland;
    xdg-desktop-portal-hyprland = pkgs.xdg-desktop-portal-hyprland;
  };
}
