{common, ...}: {
  imports = [
    ../all-users
    common.bundles.fox
    ./apps.nix
    ./packages.nix
    ./theme.nix
    ./hyprland.nix
    ./waybar.nix
    ./lockscreen.nix
    ./wezterm
    ./shell.nix
    ./dev.nix
    ./secrets.nix
    ./nvim
  ];
}
