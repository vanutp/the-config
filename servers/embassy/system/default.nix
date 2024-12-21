{common, ...}: {
  imports = [
    common.bundles.server.system
    common.blocks.vds-networking
    ./containers
    ./disko.nix
    ./gitlab-ssh-shim.nix
    ./hardware-configuration.nix
    ./mailcow.nix
    ./secrets.nix
    ./traefik.nix
    ./users.nix
    ./vhap-compose-update.nix
    ./wireguard.nix
  ];

  networking.hostName = "embassy";

  time.timeZone = "Europe/Moscow";

  systemd.coredump.extraConfig = "Storage=none";
}
