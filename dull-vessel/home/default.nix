{
  common,
  pkgs,
  ...
}: {
  imports = [
    common.bundles.fox
    ./apps.nix
    ./packages.nix
    ./theme.nix
    ./hyprland.nix
    ./waybar.nix
    ./ags
    ./lockscreen.nix
    ./wezterm
    ./shell.nix
    ./dev.nix
    ./secrets.nix
  ];

  home.packages = with pkgs; [
    neovim
  ];
}
