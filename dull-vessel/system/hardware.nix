{pkgs, ...}: {
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
    opengl.enable = true;
    opentabletdriver.enable = true;
  };

  services = {
    printing = {
      enable = true;
      drivers = [
        pkgs.cups-kyodialog
      ];
    };
    blueman.enable = true;
    udev.packages = [pkgs.via];
    upower.enable = true;
    power-profiles-daemon.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
  };
}
