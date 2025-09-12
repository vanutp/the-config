{...}: {
  imports = [
    ./containers
    ./disko.nix
    ./hardware-configuration.nix
    ./network.nix
    ./traefik.nix
    ./ukurboot.nix
    ./users.nix
    ./volumes.nix
  ];

  boot.loader.grub.enable = true;

  time.timeZone = "Europe/Berlin";

  setup.computerType = "server";

  systemd.network.wait-online.enable = false;

  networking.hostId = "1dc14032";
}
