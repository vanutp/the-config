{common, ...}: {
  imports = [
    common.bundles.server.system
    common.blocks.vds-networking
    common.blocks.traefik
    ./mailcow.nix
    ./hardware-configuration.nix
    ./disko.nix
    ./secrets.nix
    ./danted.nix
    ./wireguard.nix
  ];

  networking.hostName = "proxyfriend";

  time.timeZone = "Europe/Moscow";

  vanutp.traefik.limits = {
    cpus = "1";
    memory = "0.5G";
  };
}
