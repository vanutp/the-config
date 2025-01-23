{
  pkgs,
  pkgs-unstable,
  self-pkgs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    package = self-pkgs.hyprland;
    portalPackage = self-pkgs.xdg-desktop-portal-hyprland;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    # TODO: is this needed?
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
    };
  };
}
