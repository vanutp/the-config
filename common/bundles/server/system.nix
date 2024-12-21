{
  pkgs,
  common,
  lib,
  ...
}: {
  imports = [
    common.bundles.system
  ];

  networking.useNetworkd = true;
  networking.useDHCP = false;
  # for `nixos-rebuild build-vm`
  virtualisation.vmVariant.networking.useDHCP = lib.mkForce true;

  security.sudo.wheelNeedsPassword = false;
  # to allow remote rebuild while connecting as non-root
  nix.settings.trusted-users = ["@wheel"];

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 2 * * SUN     root     cd /home/fox/backup; xonsh backup.xsh >> /home/fox/backup/backup.log 2>&1"
    ];
  };

  environment.systemPackages = with pkgs; [
    (xonsh.override {
      extraPackages = (
        ps: with ps; [humanize]
      );
    })
  ];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
  '';
}
