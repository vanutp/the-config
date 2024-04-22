{...}: {
  imports = [
    ../all-users
    ../../common/fox
    ./packages.nix
    ./theme.nix
    ./hyprland.nix
    ./waybar.nix
    ./lockscreen.nix
    ./wezterm
    ./shell.nix
    ./dev.nix
    ./secrets.nix
  ];
}
