{
  pkgs,
  inputs,
  ...
}: let
  plains-portal = inputs.plains-portal.packages.${pkgs.system}.default;
in {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      plains-portal
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    configPackages = with pkgs; [hyprland];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Settings" = "plains-portal";
    };
  };

  systemd.packages = [plains-portal];
  systemd.user.services.plains-portal.wantedBy = ["default.target"];
}
