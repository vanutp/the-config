{...}: {
  imports = [
    ../users-common
    ./packages.nix
    ./theme.nix
    ./hyprland.nix
    ./waybar.nix
    ./security.nix
    ./lockscreen.nix
    ./wezterm
    ./shell
    ./dev.nix
  ];

  home.username = "fox";
  home.homeDirectory = "/home/fox";
}
