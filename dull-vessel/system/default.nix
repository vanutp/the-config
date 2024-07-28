{
  pkgs,
  common,
  ...
}: {
  imports = [
    common.bundles.system
    ./secrets.nix
    ./hardware-configuration.nix
    ./security.nix
    ./wireguard.nix
    ./strongswan.nix
    ./veyon
    ./steam.nix
    ./dev.nix
    ./audio.nix
    ./portals.nix
    ./login.nix
    ./hardware.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  security.pam.services.swaylock = {
    fprintAuth = true;
    allowNullPassword = true;
  };

  networking.hostName = "dull-vessel";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;
  users.extraGroups.networkmanager.members = ["fox"];
  networking.nameservers = ["1.1.1.1"];
  services.resolved.enable = true;

  programs.dconf.enable = true;
  services.gpm.enable = true;
  programs.gamemode.enable = true;
  users.extraGroups.gamemode.members = ["fox"];
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  boot.supportedFilesystems = ["ntfs"];
  virtualisation.waydroid.enable = true;
}
