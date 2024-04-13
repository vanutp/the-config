# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{pkgs, ...}: {
  imports = [
    ../../common/system
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
  users.extraGroups.networkmanager.members = ["fox"];

  services.printing.enable = true;

  programs.dconf.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.gpm.enable = true;
  hardware.opengl.enable = true;

  services.udev.packages = with pkgs; [
    via
  ];

  services = {
    upower.enable = true;
    power-profiles-daemon.enable = true;
  };

  programs.gamemode.enable = true;

  services.flatpak.enable = true;

  services.gvfs.enable = true;
  boot.supportedFilesystems = ["ntfs"];

  services.fprintd.enable = true;

  services.fwupd.enable = true;
}
