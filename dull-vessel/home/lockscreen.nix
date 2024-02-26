{
  config,
  pkgs,
  lib,
  ...
}: let
  swaylockPkg = pkgs.swaylock-effects;
  swaylockCmd = "${lib.getExe swaylockPkg} -f";
in {
  programs.swaylock = {
    enable = true;
    package = swaylockPkg;
    settings = {
      image = "${config.preferences.wallpaper}";
      font = config.preferences.font.monospace;
      effect-blur = "20x3";
    };
  };

  services.swayidle = {
    enable = true;
    events = [
      {
        event = "lock";
        command = swaylockCmd;
      }
      {
        event = "unlock";
        command = "${lib.getExe' pkgs.psmisc "killall"} -s USR1 swaylock";
      }
      {
        event = "before-sleep";
        command = swaylockCmd;
      }
    ];
    timeouts = [
      {
        timeout = 300;
        command = swaylockCmd;
      }
      {
        timeout = 600;
        command = "${lib.getExe' pkgs.hyprland "hyprctl"} dispatch dpms off";
        resumeCommand = "${lib.getExe' pkgs.hyprland "hyprctl"} dispatch dpms on";
      }
    ];
  };
}
