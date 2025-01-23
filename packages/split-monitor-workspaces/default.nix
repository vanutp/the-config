{
  pkgs,
  self',
  ...
}: {
  packages.split-monitor-workspaces = import ./package.nix {
    inherit pkgs;
    inherit (self'.packages) hyprland;
  };
}
