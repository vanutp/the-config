{config, pkgs, ...}: {
  imports = [
    ../../common/system
  ];

  networking.useNetworkd = true;
  # is running under build-vm
  networking.useDHCP = config.virtualisation.vmVariant != {};

  security.sudo.wheelNeedsPassword = false;

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
}
