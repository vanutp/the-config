{common, ...}: {
  imports = [
    common.bundles.server.system
    common.blocks.vds-networking
    common.blocks.traefik
    ./traefik.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ./wireguard.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "s1";

  time.timeZone = "Europe/Moscow";
}
