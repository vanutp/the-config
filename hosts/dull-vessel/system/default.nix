{pkgs, ...}: {
  imports = [
    ./composter-tests
    ./veyon
    ./apps.nix
    ./audio.nix
    ./dev.nix
    ./fonts.nix
    ./hardware-configuration.nix
    ./hardware.nix
    ./login.nix
    ./logiops.nix
    ./portals.nix
    ./security.nix
    ./strongswan.nix
    ./wireguard.nix
  ];

  setup.computerType = "laptop";

  time.timeZone = "Europe/Berlin";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  security.pam.services.swaylock = {
    fprintAuth = true;
    allowNullPassword = true;
  };

  networking.networkmanager.enable = true;
  networking.networkmanager.logLevel = "INFO";
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.NetworkManager.wantedBy = ["multi-user.target"];
  users.groups.networkmanager.members = ["fox"];
  networking.nameservers = ["1.1.1.1"];
  services.resolved.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_default_ttl" = 65;

  programs.dconf.enable = true;
  services.gpm.enable = true;
  programs.gamemode.enable = true;
  users.groups.gamemode.members = ["fox"];
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  boot.supportedFilesystems = ["ntfs"];

  programs.nix-ld.enable = true;

  services.neard.enable = true;
}
