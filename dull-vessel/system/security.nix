{
  pkgs,
  inputs,
  lib,
  ...
}: {
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  # secure boot
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  environment.systemPackages = with pkgs; [
    sbctl
    tpm2-tools
  ];
  # Lanzaboote currently replaces the systemd-boot module.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # tpm
  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices.root.crypttabExtraOpts = [
    "tpm2-device=auto"
  ];
}
