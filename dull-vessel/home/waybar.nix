{
  pkgs,
  lib,
  config,
  ...
}: {
  services.blueman-applet.enable = true;

  programs.waybar = let
    vpns = with pkgs; (writeShellScript "vpns" ''
      set -e
      work_vpn_state=$(${lib.getExe' networkmanager "nmcli"} -g GENERAL.STATE connection show 'work')
      wg_vpns=$(${lib.getExe wireguard-tools} show interfaces)
      if [[ -n $work_vpn_state ]]; then
        if [[ -n $wg_vpns ]]; then
          active_vpns="work $wg_vpns"
        else
          active_vpns="work"
        fi
      else
        active_vpns="$wg_vpns"
      fi
      echo '{"text": "'"$active_vpns"'", "alt": "", "tooltip": "", "class": "", "percentage": 0 }'
    '');
    plains-portal-config-path = "${config.xdg.configHome}/plains-portal/config.toml";
    theme = pkgs.foxlib.writePythonScript "theme" ''
      import os
      import sys
      import tomllib
      import json
      import subprocess
      SIGRTMIN = 34
      ICONS = {
        'light': '\uf522 ',
        'dark': '\uf4ee ',
      }
      fn = '${plains-portal-config-path}'
      if os.path.isfile(fn):
          with open(fn, 'rb') as f:
              data = tomllib.load(f)
      else:
          data = {}
      color_scheme = data.get('color-scheme', 'light')
      if sys.argv[1] == 'get':
          print(json.dumps({'text': ICONS.get(color_scheme, 'unknown theme') }))
      elif sys.argv[1] == 'toggle':
          if color_scheme == 'light':
              data['color-scheme'] = 'dark'
          else:
              data['color-scheme'] = 'light'
          os.makedirs(os.path.dirname(fn), exist_ok=True)
          with open(fn, 'w') as f:
              f.write('''.join(f'{k} = "{v}"\n' for k, v in data.items()))
          subprocess.check_call(f'kill -{SIGRTMIN + 1} $(pgrep waybar)', shell=True)
      else:
          raise ValueError()
    '';
  in {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        "layer" = "top";
        "position" = "top";
        "height" = 30;
        "spacing" = 10;
        "modules-left" = ["hyprland/workspaces" "hyprland/submap"];
        "modules-center" = [];
        "modules-right" = [
          "tray"
          "custom/vpns"
          "custom/theme"
          "pulseaudio"
          "memory"
          "hyprland/language"
          "battery"
          "clock"
        ];
        "custom/vpns" = {
          "exec" = vpns;
          "interval" = 5;
          "return-type" = "json";
        };
        "custom/theme" = {
          "exec" = "${theme} get";
          "on-click" = "${theme} toggle";
          "interval" = "once";
          "signal" = 1;
          "return-type" = "json";
        };
        "hyprland/workspaces" = {
          "format" = "{icon}";
          "on-scroll-up" = "hyprctl dispatch workspace e-1";
          "on-scroll-down" = "hyprctl dispatch workspace e+1";
          "format-icons" = {
            "default" = "";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "11" = "1";
            "12" = "2";
            "13" = "3";
            "14" = "4";
            "15" = "5";
            "16" = "6";
            "17" = "7";
            "18" = "8";
            "19" = "9";
            "active" = "󱓻";
            "urgent" = "󱓻";
          };
          "persistent-workspaces" = {
            "eDP-1" = [1 2 3 4 5];
            "DP-1" = [11 12 13 14 15];
            "HDMI-A-1" = [11 12 13 14 15];
          };
        };
        "hyprland/window" = {
          "max-length" = 200;
          "rewrite" = {
            "(.*) - Google Chrome" = "$1";
            "(.*) @ [^@]*$" = "$1";
          };
          "separate-outputs" = true;
        };
        "tray" = {
          "spacing" = 10;
        };
        "hyprland/language" = {
          "format" = "{}";
          "format-de" = "en";
          "format-ru" = "ru";
        };
        "mpris" = {
          "format" = "{status_icon} {player} {title} — {artist}";
          "status-icons" = {
            "playing" = "";
            "paused" = "";
          };
        };
        "clock" = {
          "tooltip-format" = "<big>{:%e %B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          "locale" = "ru_RU.UTF-8";
          "interval" = 1;
          "format" = "{:%H:%M:%S}";
        };
        "memory" = {
          "interval" = 5;
          "format" = "󰍛 {}%";
        };
        "battery" = {
          "bat" = "BAT0";
          "format" = "{capacity}% {icon}";
          "format-full" = "";
          "format-icons" = {
            "charging" = ["󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
            "default" = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          };
          "interval" = 5;
          "states" = {
            "warning" = 30;
            "critical" = 10;
          };
          "tooltip" = false;
        };
        "pulseaudio" = {
          "format" = "{icon} {volume}%";
          "format-bluetooth" = "󰂰 {volume}%";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "nospacing" = 1;
          "tooltip-format" = "{format_source}";
          "format-muted" = "󰝟";
          "format-icons" = {
            "headphone" = "";
            "default" = ["󰖀" "󰕾" ""];
          };
          "scroll-step" = 1;
          "on-click" = lib.getExe pkgs.pavucontrol;
        };
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: ${config.preferences.font.monospace};
        font-size: 13px;
      }

      window#waybar {
        background-color: transparent;
        transition-property: background-color;
        transition-duration: 0.5s;
      }

      window#waybar.hidden {
        opacity: 0.5;
      }

      #workspaces {
        background-color: transparent;
      }

      #workspaces button {
        all: initial; /* Remove GTK theme values (waybar #1351) */
        min-width: 0; /* Fix weird spacing in materia (waybar #450) */
        box-shadow: inset 0 -3px transparent; /* Use box-shadow instead of border so the text isn't offset */
        padding: 4px 18px;
        margin-top: 5px;
        margin-left: 10px;
        margin-bottom: 0;
        border-radius: 4px;
        background-color: #1e1e2e;
        color: #cdd6f4;
      }

      #workspaces button.active {
        color: #1e1e2e;
        background-color: #cdd6f4;
      }

      #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
        color: #1e1e2e;
        background-color: #cdd6f4;
      }

      #workspaces button.urgent {
        background-color: #f38ba8;
      }

      #custom-vpns,
      #custom-theme,
      #language,
      #memory,
      #battery,
      #pulseaudio,
      #clock,
      #tray {
        border-radius: 4px;
        margin-top: 5px;
        margin-bottom: 0;
        padding: 4px 12px;
        background-color: #1e1e2e;
        color: #181825;
      }

      #memory {
        background-color: #fab387;
      }
      #battery {
        background-color: #f38ba8;
      }
      @keyframes blink {
        to {
          background-color: #f38ba8;
          color: #181825;
        }
      }

      #battery.warning,
      #battery.critical,
      #battery.urgent {
        background-color: #ff0048;
        color: #181825;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      #battery.charging {
        background-color: #a6e3a1;
      }

      #pulseaudio {
        background-color: #f9e2af;
      }

      #clock {
        background-color: #cba6f7;
        margin-right: 10px;
      }

      #language {
        background-color: #a6e3a1;
        min-width: 16px;
      }

      tooltip {
        border-radius: 8px;
        padding: 15px;
        background-color: #131822;
      }

      tooltip label {
        padding: 5px;
        background-color: #131822;
      }

      #custom-vpns {
        background-color: #89b4fa;
      }

      #custom-theme {
        padding: 4px 7px 4px 10px;
        background-color: #74c7ec;
      }
    '';
  };
}
