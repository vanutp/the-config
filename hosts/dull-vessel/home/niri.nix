{
  pkgs,
  config,
  lib,
  ...
}: let
  mkKdl = import ./mkKdl.nix pkgs;
  yubikey-totp = pkgs.writeShellScript "yubikey-totp" ''
    ykman oath accounts code -s "$(ykman oath accounts list | tofi)" \
    > >(sd '\n' ''' | wl-copy) \
    2> >(python -c "
    import sys, subprocess
    while inp := sys.stdin.readline().strip():
      subprocess.check_call(['dunstify', inp])
    " && dunstify 'Copied!')
  '';
in {
  programs.wpaperd = {
    enable = true;
    settings = {
      any.path = config.preferences.wallpaper;
    };
  };
  systemd.user.sessionServices = [
    {
      package = pkgs.xwayland-satellite;
      args = [":0"];
    }
    {
      package = pkgs.hyprpolkitagent;
      binary = "/libexec/hyprpolkitagent";
    }
    {package = pkgs.wpaperd;}
  ];
  home.packages = [
    pkgs.niri
    (pkgs.writeScriptBin "default-user-session" ''
      #!${lib.getExe pkgs.bash}
      exec ${lib.getExe pkgs.niri} --session
    '')
  ];
  services = {
    network-manager-applet.enable = true;
    playerctld.enable = true;
  };

  xdg.configFile."niri/config.kdl".source =
    mkKdl "config.kdl"
    ({
      block,
      section,
      node,
      ...
    }: [
      "prefer-no-csd"
      (node "spawn-at-startup" ["sh" "-c" "copyq --start-server && copyq hide"])
      (block "hotkey-overlay" "skip-at-startup")
      (node "screenshot-path" "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png")
      (block "input" [
        "focus-follows-mouse"
        (
          block "keyboard"
          (block "xkb" {
            layout = "de,ru";
            variant = "us,";
            options = "grp:caps_toggle";
          })
        )
        (block "touchpad" [
          "tap"
          "natural-scroll"
        ])
        (block "mouse" {
          scroll-factor = 1.5;
        })
      ])
      (section "output" "eDP-1" {
        scale = 1.25;
        position = {
          x = 0;
          y = 0;
        };
      })
      (section "output" "DP-1" {
        scale = 1.25;
        position = {
          x = 1536;
          y = 0;
        };
      })
      (block "layout" [
        (node "gaps" 8)
        (node "center-focused-column" "never")
        (block "preset-column-widths" [
          (node "proportion" 0.33333)
          (node "proportion" 0.5)
          (node "proportion" 0.66667)
        ])
        (block "default-column-width" {
          proportion = 1.0;
        })
        (block "focus-ring" {
          width = 2;
          active-gradient = {
            from = "#cba6f7";
            to = "#89b4fa";
            angle = 135;
          };
          inactive-color = "#313244";
        })
      ])
      (block "window-rule" {
        geometry-corner-radius = 5;
        clip-to-geometry = true;
      })
      (block "window-rule" [
        (node "match" {app-id = "com.github.hluk.copyq";})
        (node "match" {app-id = ".blueman-manager-wrapped";})
        (node "match" {app-id = "pavucontrol";})
        (node "match" {app-id = "org.fcitx.";})
        (node "open-floating" true)
      ])
      (block "environment" {
        DISPLAY = ":0";
        NIXOS_OZONE_WL = "1";
      })
      (block "binds" (
        let
          spawn = node "spawn";
          bindsWith = opts: lib.mapAttrsToList (key: section key opts);
          binds = bindsWith [];
        in
          lib.flatten [
            (binds {
              "Super+Return" = spawn "ghostty";
              "Super+Escape" = spawn ["loginctl" "lock-session"];
              "Super+Shift+A" = spawn yubikey-totp;
              "Super+D" = spawn ["tofi-drun" "--drun-launch=true"];
              "Super+E" = spawn "thunar";
              "Ctrl+Shift+D" = spawn ["copyq" "toggle"];
              "Super+S" = "screenshot";

              "Super+Shift+Space" = "toggle-window-floating";
              "Super+Shift+Q" = "close-window";
              "Super+R" = "switch-preset-column-width";
              "Super+Shift+R" = "switch-preset-window-height";
              "Super+F" = "maximize-column";
              "Super+H" = "reset-window-height";
              "Super+Shift+F" = "fullscreen-window";
              "Mod+Minus" = node "set-column-width" "-10%";
              "Mod+Shift+Minus" = node "set-window-height" "-10%";
              "Mod+Equal" = node "set-column-width" "+10%";
              "Mod+Shift+Equal" = node "set-window-height" "+10%";
              "Mod+Home" = "focus-column-first";
              "Mod+Shift+Home" = "move-column-to-first";
              "Mod+End" = "focus-column-last";
              "Mod+Shift+End" = "move-column-to-last";

              "Super+Down" = "focus-window-down";
              "Super+Shift+Down" = "move-window-down";
              "Super+Up" = "focus-window-up";
              "Super+Shift+Up" = "move-window-up";
              "Super+Left" = "focus-column-left";
              "Super+Shift+Left" = "move-column-left";
              "Super+Right" = "focus-column-right";
              "Super+Shift+Right" = "move-column-right";
            })

            (bindsWith {allow-when-locked = true;} {
              XF86AudioRaiseVolume =
                spawn
                ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" "-l" "1.0"];
              XF86AudioLowerVolume =
                spawn
                ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
              XF86AudioMute =
                spawn
                ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
              XF86MonBrightnessUp = spawn ["brightnessctl" "s" "5%+"];
              XF86MonBrightnessDown = spawn ["brightnessctl" "s" "5%-"];

              XF86AudioPlay = spawn ["playerctl" "play-pause"];
              XF86AudioPause = spawn ["playerctl" "pause"];
              XF86AudioStop = spawn ["playerctl" "pause"];
              #XF86AudioPlayPause = spawn ["playerctl" "play-pause"];
              XF86PickupPhone = spawn ["playerctl" "play-pause"];
              XF86AudioNext = spawn ["playerctl" "next"];
              XF86HangupPhone = spawn ["playerctl" "next"];
              XF86AudioPrev = spawn ["playerctl" "previous"];
              XF86NotificationCenter = spawn ["playerctl" "previous"];
            })

            (
              lib.forEach (lib.range 1 9)
              (
                n:
                  binds {
                    "Super+${toString n}" = node "focus-workspace" n;
                    "Super+Shift+${toString n}" = node "move-column-to-workspace" n;
                    "Super+Shift+Ctrl+${toString n}" = node "move-window-to-workspace" n;
                  }
              )
            )
          ]
      ))
    ]);
}
