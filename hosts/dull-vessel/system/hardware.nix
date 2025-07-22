{
  pkgs,
  self-pkgs,
  ...
}: {
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          FastConnectable = true;
        };
      };
    };
    opentabletdriver.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services = {
    printing = {
      enable = true;
      drivers = [
        self-pkgs.cups-kyodialog
      ];
    };
    blueman.enable = true;
    udev.packages = [
      pkgs.via
      pkgs.qmk-udev-rules
    ];
    upower.enable = true;
    power-profiles-daemon.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    # fn+4 is the suspend key for some reason
    logind.suspendKey = "ignore";
  };
}
