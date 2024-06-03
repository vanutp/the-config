{common, ...}: {
  imports = [
    common.bundles.server.system
    common.blocks.vds-networking
    common.blocks.traefik
    ./hardware-configuration.nix
    ./disko.nix
    ./secrets.nix
    ./danted.nix
    ./wireguard.nix
  ];

  networking.hostName = "proxyfriend";

  time.timeZone = "Europe/Moscow";
}
