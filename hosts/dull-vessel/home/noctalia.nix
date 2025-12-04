{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: let
  dconf = lib.getExe pkgs.dconf;
  theme = pkgs.writers.writePython3 "theme" {flakeIgnore = ["E501"];} ''
    import sys
    import json
    import subprocess
    from configparser import ConfigParser
    QTCT_CONFIG_PATH = '${config.xdg.configHome}/qt6ct/qt6ct.conf'
    SIGRTMIN = 34
    ICONS = {
        'default': '\uf522 ',
        'prefer-light': '\uf522 ',
        'prefer-dark': '\uf4ee ',
    }
    color_scheme = subprocess.check_output(['${dconf}', 'read', '/org/gnome/desktop/interface/color-scheme']).decode().strip("\n'")
    if sys.argv[1] == 'get':
        print(json.dumps({'text': ICONS.get(color_scheme, 'unknown theme')}))
    elif sys.argv[1] == 'toggle':
        if color_scheme in ['default', 'prefer-light']:
            color_scheme = 'prefer-dark'
            gtk_theme = 'Adwaita-dark'
            qt_color_scheme_path = '${pkgs.qt6Packages.qt6ct}/share/qt6ct/colors/darker.conf'
            qt_icon_theme = 'breeze-dark'
        else:
            color_scheme = 'default'
            gtk_theme = 'Adwaita'
            qt_color_scheme_path = None
            qt_icon_theme = 'breeze'
        subprocess.check_call(['${dconf}', 'write', '/org/gnome/desktop/interface/color-scheme', f'"{color_scheme}"'])
        subprocess.check_call(['${dconf}', 'write', '/org/gnome/desktop/interface/gtk-theme', f'"{gtk_theme}"'])
        qt_cfg = ConfigParser()
        qt_cfg.read(QTCT_CONFIG_PATH)
        if not qt_cfg.has_section('Appearance'):
            qt_cfg.add_section('Appearance')
        qt_cfg.set('Appearance', 'style', 'Breeze')
        if qt_color_scheme_path:
            qt_cfg.set('Appearance', 'custom_palette', 'true')
            qt_cfg.set('Appearance', 'color_scheme_path', qt_color_scheme_path)
        else:
            qt_cfg.set('Appearance', 'custom_palette', 'false')
            qt_cfg.remove_option('Appearance', 'color_scheme_path')
        qt_cfg.set('Appearance', 'icon_theme', qt_icon_theme)
        with open(QTCT_CONFIG_PATH, 'w') as f:
            qt_cfg.write(f, space_around_delimiters=False)
    else:
        raise ValueError()
  '';
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];
  home.packages = [
    # TODO
    (pkgs.writeShellScriptBin "theme" ''exec ${theme} "$@"'')
  ];
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        position = "top";
        widgets = {
          left = [
            {id = "Workspace";}
            {
              id = "SystemMonitor";
              showCpuTemp = true;
              showCpuUsage = true;
              showDiskUsage = false;
              showMemoryUsage = true;
              showMemoryAsPercent = true;
              showNetworkStats = false;
            }
            {id = "NightLight";}
            {id = "DarkMode";}
            {id = "ScreenRecorder";}
            {
              id = "MediaMini";
              hideMode = "idle";
              maxWidth = 30;
              showProgressRing = false;
            }
          ];
          center = [];
          right = [
            {
              id = "Tray";
              drawerEnabled = false;
            }
            {id = "WiFi";}
            {
              id = "VPN";
              displayMode = "alwaysShow";
            }
            {id = "Bluetooth";}
            {id = "Volume";}
            {
              id = "KeyboardLayout";
              displayMode = "forceOpen";
            }
            {
              id = "Battery";
              displayMode = "alwaysShow";
            }
            {id = "ControlCenter";}
            {
              id = "Clock";
              useCustomFont = true;
              customFont = config.preferences.font.monospace;
              formatHorizontal = "HH:mm:ss ddd, dd.MM";
              formatVertical = "HH mm ss";
            }
          ];
        };
      };
      brightness.brightnessStep = 2;
      colorSchemes.predefinedScheme = "Rosepine"; # TODO
      dock.enabled = false;
      general = {
        animationDisabled = true;
        dimmerOpacity = 0;
        enableShadows = false;
      };
      hooks = {
        enabled = true;
        darkModeChange = "${theme} toggle";
      };
      location.name = "Bremen";
      nightLight.nightTemp = 5000;
      notifications.enableKeyboardLayoutToast = false;
      sessionMenu = {
        enableCountdown = false;
        powerOptions = [
          {
            action = "lock";
            enabled = true;
          }
          {
            action = "logout";
            enabled = true;
          }
          {
            action = "suspend";
            enabled = true;
          }
          {
            action = "reboot";
            enabled = true;
          }
          {
            action = "shutdown";
            enabled = true;
          }
        ];
      };
      setupCompleted = true;
      ui.fontFixed = config.preferences.font.monospace;
      wallpaper.defaultWallpaper = config.preferences.wallpaper;
    };
    systemd.enable = true;
  };
}
