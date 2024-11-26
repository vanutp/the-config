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
    package = pkgs-unstable.mesa.drivers;
    enable32Bit = true;
    package32 = pkgs-unstable.pkgsi686Linux.mesa.drivers;
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
