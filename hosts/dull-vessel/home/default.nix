{...}: {
  imports = [
    ./apps.nix
    ./packages.nix
    ./theme.nix
    ./hyprland.nix
    ./waybar.nix
    ./ags
    ./lockscreen.nix
    ./shell.nix
    ./dev.nix
    ./secrets.nix
  ];

  setup.computerType = "laptop";

  home.username = "fox";
  home.homeDirectory = "/home/fox";
}
