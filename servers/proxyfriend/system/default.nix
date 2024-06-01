{common, ...}: {
  imports = [
    common.bundles.server.system
    common.blocks.vds-networking
    common.blocks.traefik
    common.blocks.docker-proxy-server
    ./hardware-configuration.nix
    ./disko.nix
    ./secrets.nix
    ./danted.nix
    ./wireguard.nix
  ];

  vanutp.traefik.acmeChallenge = "http";

  networking.hostName = "proxyfriend";

  time.timeZone = "Europe/Moscow";
}
