{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    configPackages = with pkgs; [hyprland];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
    };
  };
}
