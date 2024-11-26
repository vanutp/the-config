{
  pkgs,
  pkgs-unstable,
  inputs,
}: {
  veyon = import ./veyon pkgs;
  _64gram = import ./_64gram pkgs;
  vhap =
    (import ./vhap/pyproject.nix {
      inherit pkgs;
      inherit (inputs) pyproject-nix;
    })
    .package;
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
  xdg-desktop-portal-hyprland = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  split-monitor-workspaces = inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces;
}
