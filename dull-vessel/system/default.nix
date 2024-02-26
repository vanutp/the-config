# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{pkgs, ...}: {
  imports = [
    ./secrets.nix
    ./hardware-configuration.nix
    ./security.nix
    ./wireguard.nix
    ./strongswan.nix
    ./veyon
    ./steam.nix
    ./dev.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  security.pam.services.swaylock = {};

  networking.hostName = "dull-vessel";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes" "repl-flake"];
  nixpkgs.config.allowUnfree = true;

  services.printing.enable = true;

  programs.dconf.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # breaks video playback in telegram and mpv for some reason
  #security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.gpm.enable = true;
  hardware.opengl.enable = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.fox = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    useDefaultShell = true;
  };

  services.udev.packages = with pkgs; [
    via
  ];

  services = {
    upower.enable = true;
    power-profiles-daemon.enable = true;
  };

  programs.gamemode.enable = true;

  programs.nix-ld.enable = true;

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    configPackages = with pkgs; [hyprland];
  };

  services.gvfs.enable = true;
  boot.supportedFilesystems = ["ntfs"];

  # Never change this
  system.stateVersion = "24.05";
}
