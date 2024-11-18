{common, ...}: {
  imports = [
    common.bundles.server.system
    common.blocks.vds-networking
    ./containers
    ./hardware-configuration.nix
    ./postgresql.nix
    ./secrets.nix
    ./wireguard.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";

  networking.hostName = "collective";

  time.timeZone = "Europe/Berlin";
}
