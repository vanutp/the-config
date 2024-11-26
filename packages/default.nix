{
  pkgs,
  pkgs-unstable,
  inputs,
}: rec {
  veyon = import ./veyon pkgs;
  _64gram = import ./_64gram pkgs;
  vhap =
    (import ./vhap/pyproject.nix {
      inherit pkgs;
      inherit (inputs) pyproject-nix;
    })
    .package;
  hyprland = pkgs.hyprland;
  xdg-desktop-portal-hyprland = pkgs.xdg-desktop-portal-hyprland;
  split-monitor-workspaces = import ./split-monitor-workspaces {inherit pkgs hyprland;};
}
