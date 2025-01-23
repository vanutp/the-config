{...}: {
  imports = [
    ./anki.nix
    ./containers
    ./dvasmp
    ./disko.nix
    ./gitlab-ssh-shim.nix
    ./hardware-configuration.nix
    ./mailcow.nix
    ./network.nix
    ./secrets.nix
    ./traefik.nix
    ./users.nix
    ./vhap-compose-update.nix
    ./wireguard.nix
  ];

  time.timeZone = "Europe/Moscow";

  setup.computerType = "server";

  systemd.coredump.extraConfig = "Storage=none";

  systemd.network.wait-online.enable = false;
}
