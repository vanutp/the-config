{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}: {
  programs.hyprlock = {
    enable = true;
    package = pkgs-unstable.hyprlock;
    settings = {
      general = {
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "${config.preferences.wallpaper}";
          blur_passes = 1;
          blur_size = 5;
        }
      ];

      input-field = [
        {
          font_family = config.preferences.font.monospace;
          size = "200, 50";
          position = "0, 0";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(205, 214, 244)";
          inner_color = "rgb(30, 30, 46)";
          outer_color = "rgb(17, 17, 27)";
          outline_thickness = 5;
          placeholder_text = ''<span foreground="##45475a">Password</span>'';
          fail_text = ''$FAIL ($ATTEMPTS)'';
        }
      ];

      label = [
        {
          font_family = config.preferences.font.monospace;
          text = "$LAYOUT[!,ru]";
          color = "rgb(255, 0, 0)";
          position = "0, -50";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  systemd.user.services.hypridle.Unit = {
    # wait unitl required env (WAYLAND_DISPLAY) is set
    After = ["graphical-session.target"];
    Requisite = "graphical-session.target";
  };

  services.hypridle = let
    lockExe = lib.getExe pkgs.hyprlock;
    lockCmd = "${lib.getExe' pkgs.systemd "systemd-run"} --user ${lockExe}";
  in {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof ${lockExe} || ${lockCmd}";
        unlock_cmd = "pkill -f -USR1 ${lockExe}";
        before_sleep_cmd = "loginctl lock-session";
      };
      listener = [
        {
          timeout = 60 * 5;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 60 * 10;
          on-timeout = "niri msg action power-off-monitors";
          on-resumt = "niri msg action power-on-monitors";
        }
      ];
    };
  };
}
