{...}: {
  imports = [
    ./anyrun.nix
    ./apps.nix
    ./dev.nix
    ./fcitx5.nix
    ./lockscreen.nix
    ./noctalia.nix
    ./niri
    ./packages.nix
    ./secrets.nix
    ./session-services.nix
    ./shell.nix
    ./terminal.nix
    ./theme.nix
  ];

  setup.computerType = "laptop";

  home.username = "fox";
  home.homeDirectory = "/home/fox";
}
