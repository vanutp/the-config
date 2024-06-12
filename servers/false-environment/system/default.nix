{
  common,
  config,
  pkgs,
  ...
}: {
  imports = [
    common.bundles.server.system
    ./hardware-configuration.nix
    ./disko.nix
    ./secrets.nix
  ];

  networking.hostName = "false-environment";

  time.timeZone = "Europe/Moscow";

  networking.wg-quick.interfaces = {
    wg0 = common.atoms.makeWg0 config {
      address = "10.1.0.6";
      isInternal = true;
      autostart = true;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  environment.systemPackages = with pkgs; [
    temurin-bin-17
  ];
  networking.firewall.allowedTCPPorts = [25565];
  networking.firewall.allowedUDPPorts = [24454];
}
