{...}: {
  imports = [
    ./anyrun.nix
    ./apps.nix
    ./dev.nix
    ./fcitx5.nix
    # ./ignis
    ./lockscreen.nix
    ./niri
    ./packages.nix
    ./secrets.nix
    ./session-services.nix
    ./shell.nix
    ./terminal.nix
    ./theme.nix
    ./waybar.nix
  ];

  setup.computerType = "laptop";

  home.username = "fox";
  home.homeDirectory = "/home/fox";
}
