{...}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./network.nix
  ];

  setup.computerType = "server";

  disko.devices.disk.main.imageSize = "3G";
}
