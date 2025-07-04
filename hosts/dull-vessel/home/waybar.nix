{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}: {
  services.blueman-applet.enable = true;

  programs.waybar = let
    fans = with pkgs; (writeShellScript "fans" ''
      set -e
      fan_speed=$(cat /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon*/fan1_input)
      if [[ $fan_speed != 0 ]]; then
        fan_speed=$(printf '%-4s' $fan_speed)
      fi
      text="󰈐 $fan_speed"
      echo '{"text": "'"$text"'", "alt": "", "tooltip": "", "class": "", "percentage": 0 }'
    '');
    # TODO: rewrite in nu
    vpns = with pkgs; (writeShellScript "vpns" ''
      set -e
      work_vpn_state=$(${lib.getExe' networkmanager "nmcli"} -g GENERAL.STATE connection show 'work')
      wg_vpns=$(${lib.getExe wireguard-tools} show interfaces)
      tailscale_exit_node=$(${lib.getExe' pkgs-unstable.tailscale "tailscale"} status --json | ${lib.getExe pkgs.jq} -r '.ExitNodeStatus.ID as $node_id | .Peer[] | select(.ID==$node_id) | .HostName')
      active_vpns=""
      if [[ -n $work_vpn_state ]]; then
        active_vpns="work"
      fi
      if [[ -n $wg_vpns ]]; then
        if [[ -n $active_vpns ]]; then
          active_vpns="$active_vpns $wg_vpns"
        else
          active_vpns="$wg_vpns"
        fi
      fi
      if [[ -n $tailscale_exit_node ]]; then
        if [[ -n $active_vpns ]]; then
          active_vpns="$active_vpns $tailscale_exit_node"
        else
          active_vpns="$tailscale_exit_node"
        fi
      fi
      echo '{"text": "'"$active_vpns"'", "alt": "", "tooltip": "", "class": "", "percentage": 0 }'
    '');
    dconf = lib.getExe pkgs.dconf;
    theme = pkgs.writers.writePython3 "theme" {flakeIgnore = ["E501"];} ''
      import sys
      import json
      import subprocess
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
          else:
              color_scheme = 'default'
              gtk_theme = 'Adwaita'
          subprocess.check_call(['${dconf}', 'write', '/org/gnome/desktop/interface/color-scheme', f'"{color_scheme}"'])
          subprocess.check_call(['${dconf}', 'write', '/org/gnome/desktop/interface/gtk-theme', f'"{gtk_theme}"'])
          subprocess.check_call(f'kill -{SIGRTMIN + 1} $(pgrep waybar)', shell=True)
      else:
          raise ValueError()
    '';
    busctl = lib.getExe' pkgs.systemd "busctl";
    gamma = pkgs.writers.writePython3 "gamma" {flakeIgnore = ["E501"];} ''
      import sys
      import json
      import subprocess
      SIGRTMIN = 34
      ICONS = {
          'normal': '\udb80\udf36',
          'night': '\udb86\ude4c',
      }
      get_cmd = '${busctl} --user get-property rs.wl-gammarelay / rs.wl.gammarelay Temperature'
      set_cmd = '${busctl} --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q'
      temp = int(subprocess.check_output(get_cmd.split()).decode().strip().removeprefix('q '))
      temp_str = 'normal' if temp == 6500 else 'night'
      if sys.argv[1] == 'get':
          print(json.dumps({'text': ICONS.get(temp_str, 'error')}))
      elif sys.argv[1] == 'toggle':
          if temp_str == 'normal':
              temp = 5000
          else:
              temp = 6500
          subprocess.check_call(set_cmd.split() + [str(temp)])
          subprocess.check_call(f'kill -{SIGRTMIN + 2} $(pgrep waybar)', shell=True)
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
        "modules-left" = ["niri/workspaces"];
        "modules-center" = [];
        "modules-right" = [
          "tray"
          "custom/vpns"
          "custom/gamma"
          "custom/theme"
          "pulseaudio"
          "temperature"
          "custom/fans"
          "niri/language"
          "battery"
          "clock"
        ];
        "custom/vpns" = {
          "exec" = vpns;
          "interval" = 5;
          "return-type" = "json";
        };
        "custom/gamma" = {
          "exec" = "${gamma} get";
          "on-click" = "${gamma} toggle";
          "interval" = "once";
          "signal" = 2;
          "return-type" = "json";
        };
        "custom/theme" = {
          "exec" = "${theme} get";
          "on-click" = "${theme} toggle";
          "interval" = "once";
          "signal" = 1;
          "return-type" = "json";
        };
        "temperature" = {
          "format" = "{temperatureC}°C ";
        };
        "custom/fans" = {
          "exec" = fans;
          "interval" = 5;
          "return-type" = "json";
        };
        "niri/workspaces" = {
          "format" = "{icon}";
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
        };
        "tray" = {
          "spacing" = 10;
        };
        "niri/language" = {
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
        "idle_inhibitor" = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "󰅶 ";
            "deactivated" = "󰾫 ";
          };
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
      #custom-gamma,
      #custom-theme,
      #language,
      #temperature,
      #custom-fans,
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

      #temperature {
        background-color: #94e2d5;
      }
      #battery {
        background-color: #89b4fa;
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
        background-color: #a6e3a1;
      }

      #clock {
        background-color: #b4befe;
        margin-right: 10px;
      }

      #language {
        background-color: #74c7ec;
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
        background-color: #eba0ac;
      }

      #custom-gamma {
        padding: 4px 10px 4px 10px;
        background-color: #fab387;
      }

      #custom-theme {
        padding: 4px 7px 4px 10px;
        background-color: #f9e2af;
      }

      #custom-fans {
        background-color: #89dceb;
      }
    '';
  };
}
