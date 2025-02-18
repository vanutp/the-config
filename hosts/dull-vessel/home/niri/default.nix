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
    (pkgs.niri.overrideAttrs (prev: let
      lockPatch = ./0001-Update-Smithay.patch;
    in {
      patches = [lockPatch] ++ prev.patches;
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (prev) src;
        name = "${prev.pname}-${prev.version}";
        patches = lockPatch;
        hash = "sha256-7Urj1pqlRENrRiaTya5j8q0Qwm8jccnf/kvkyynu4E0=";
      };
    }))
    (pkgs.writeScriptBin "default-user-session" ''
      #!${lib.getExe pkgs.bash}
      exec ${lib.getExe pkgs.niri} --session
    '')
  ];
  services = {
    network-manager-applet.enable = true;
    playerctld.enable = true;
  };

  systemd.user.services.network-manager-applet.Unit = {
    # start after niri and remove tray.target
    After = lib.mkForce ["graphical-session.target"];
    Requires = lib.mkForce [];
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
        NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib
          pkgs.libz
          pkgs.openssl.out
          pkgs.wayland
          pkgs.libxkbcommon
          pkgs.pkgs.libGL
        ];
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
              "Super+E" = spawn ["nautilus" "-w"];
              "Ctrl+Shift+D" = spawn ["copyq" "toggle"];
              "Super+S" = "screenshot";

              "Super+Shift+Space" = "toggle-window-floating";
              "Super+Shift+Q" = "close-window";
              "Super+R" = "switch-preset-column-width";
              "Super+Ctrl+R" = "switch-preset-window-height";
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

              "Super+Down" = "focus-window-or-workspace-down";
              "Super+Shift+Down" = "move-window-down-or-to-workspace-down";
              "Super+Up" = "focus-window-or-workspace-up";
              "Super+Shift+Up" = "move-window-up-or-to-workspace-up";
              "Super+Left" = "focus-column-left";
              "Super+Shift+Left" = "move-column-left";
              "Super+Right" = "focus-column-right";
              "Super+Shift+Right" = "move-column-right";

              "Super+Ctrl+Shift+Down" = "move-workspace-down";
              "Super+Ctrl+Shift+Up" = "move-workspace-up";
              "Super+Ctrl+Right" = "focus-monitor-right";
              "Super+Ctrl+Shift+Right" = "move-workspace-to-monitor-right";
              "Super+Ctrl+Shift+Alt+Right" = "move-column-to-monitor-right";
              "Super+Ctrl+Left" = "focus-monitor-left";
              "Super+Ctrl+Shift+Left" = "move-workspace-to-monitor-left";
              "Super+Ctrl+Shift+Alt+Left" = "move-column-to-monitor-left";
            })

            (bindsWith {cooldown-ms = 150;} {
              "Super+WheelScrollUp" = "focus-workspace-up";
              "Super+Shift+WheelScrollUp" = "move-column-to-workspace-up";
              "Super+WheelScrollDown" = "focus-workspace-down";
              "Super+Shift+WheelScrollDown" = "move-column-to-workspace-down";
              "Super+WheelScrollLeft" = "focus-column-left";
              "Super+Shift+WheelScrollLeft" = "move-column-left";
              "Super+WheelScrollRight" = "focus-column-right";
              "Super+Shift+WheelScrollRight" = "move-column-right";
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

              "Super+Shift+F5" = spawn ["bash" "-c" "niri msg action power-off-monitors && niri msg action power-on-monitors"];
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
