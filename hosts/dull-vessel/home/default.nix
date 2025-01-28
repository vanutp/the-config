{...}: {
  imports = [
    ./ags
    ./apps.nix
    ./dev.nix
    ./dunst.nix
    ./fcitx5.nix
    ./lockscreen.nix
    ./niri.nix
    ./packages.nix
    ./secrets.nix
    ./session-services.nix
    ./shell.nix
    ./terminal.nix
    ./theme.nix
    ./tofi.nix
    ./waybar.nix
  ];

  setup.computerType = "laptop";

  home.username = "fox";
  home.homeDirectory = "/home/fox";
}
