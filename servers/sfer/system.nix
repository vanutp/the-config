{common, ...}: {
  imports = [
    common.bundles.server.system
    common.blocks.vds-networking
    ./hardware-configuration.nix
    ./disko.nix
  ];

  disko.devices.disk.main.imageSize = "3G";

  networking.hostName = "sfer";

  time.timeZone = "Europe/Moscow";
}
