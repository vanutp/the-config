{pkgs, ...}: {
  imports = [
    ./_64gram
    ./cups-kyodialog
    ./veyon
    ./vhap
  ];

  packages = {
    hyprland = pkgs.hyprland;
    xdg-desktop-portal-hyprland = pkgs.xdg-desktop-portal-hyprland;
  };
}
