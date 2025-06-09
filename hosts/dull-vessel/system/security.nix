{
  pkgs,
  inputs,
  lib,
  ...
}: {
  services.pcscd.enable = true;

  # secure boot
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  environment.systemPackages = with pkgs; [
    sbctl
    tpm2-tools
  ];
  # Lanzaboote replaces the systemd-boot module.
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

  # hardening
  systemd.enableEmergencyMode = false;
  boot.kernelParams = [
    "rd.systemd.gpt_auto=0"
  ];
}
