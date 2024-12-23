{
  config,
  pkgs,
  lib,
  self-pkgs,
  ...
}: let
  yubikey-totp = pkgs.writeShellScript "yubikey-totp" ''
    ykman oath accounts code -s "$(ykman oath accounts list | tofi)" \
    > >(sd '\n' ''' | wl-copy) \
    2> >(python -c "
    import sys, subprocess
    while inp := sys.stdin.readline().strip():
      subprocess.check_call(['dunstify', inp])
    " && dunstify 'Copied!')
  '';
  switch-layout = pkgs.writeShellScript "switch-layout" ''
    hyprctl switchxkblayout at-translated-set-2-keyboard next
  '';
in {
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ${config.preferences.wallpaper}
    wallpaper = ,${config.preferences.wallpaper}

    splash = false
  '';

  services.network-manager-applet.enable = true;

  services.dunst = {
    enable = true;
    settings = {
      global = {
        frame_color = "#89B4FA";
        separator_color = "frame";
        corner_radius = 5;
      };

      urgency_low = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
      };

      urgency_normal = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
      };

      urgency_critical = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
        frame_color = "#FAB387";
      };
    };
  };

  programs.tofi = {
    enable = true;
    settings = {
      font = config.preferences.font.monospace-path;
      font-size = 13;
      hint-font = false;
      width = 640;
      height = 360;
      text-color = "#cdd6f4";
      prompt-color = "#f38ba8";
      selection-color = "#f9e2af";
      background-color = "#1e1e2e";
      border-width = 2;
      border-color = "#74c7ec";
      outline-width = 0;
      corner-radius = 5;
      padding-left = 16;
      padding-right = 16;
      prompt-text = "\"\"";
    };
  };

  home.activation.write-hyprland-monitors = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "${config.xdg.configHome}/hypr"
    run cat > "${config.xdg.configHome}/hypr/monitors.conf" <<EOF
    monitor = eDP-1,1920x1200@60,0x0,1.25
    monitor = DP-1,1920x1080@60,1536x0,1.25
    #monitor = HDMI-A-1,1920x1080@60,1536x0,1.25
    monitor = ,preferred,auto,1,mirror,eDP-1
    EOF
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    package = self-pkgs.hyprland;
    plugins = [
      self-pkgs.split-monitor-workspaces
    ];
    systemd.variables = ["--all"];
    catppuccin.enable = true;
    settings = {
      source = [
        "${config.xdg.configHome}/hypr/monitors.conf"
      ];

      xwayland.force_zero_scaling = true;

      exec-once = [
        "hyprpaper"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "copyq --start-server"
        "playerctld daemon"
        "fcitx5 -d -r"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "GTK_USE_PORTAL,1" # make gtk applications use portal instead of builtin gtk file picker
        "NIXOS_OZONE_WL,1"
        (
          "NIX_LD_LIBRARY_PATH,"
          + (pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc.lib
            pkgs.libz
            pkgs.openssl.out
            pkgs.wayland
            pkgs.libxkbcommon
            pkgs.pkgs.libGL
          ])
        )
      ];

      input = {
        kb_layout = "de,ru";
        kb_variant = "us,";
        kb_options = "grp:caps_toggle";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = true;
        };
      };

      # TODO: remove/move to old laptop specific config
      device = {
        name = "elan0504:01-04f3:3091-touchpad";
        sensitivity = 0.3;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "$teal $sapphire 45deg";
        "col.inactive_border" = "$surface0";

        layout = "dwindle";

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };

      group = {
        "col.border_active" = "$teal $sapphire 45deg";
        "col.border_inactive" = "$surface0";

        groupbar = {
          font_family = config.preferences.font.monospace;
          render_titles = false;
          height = 1;
          "col.active" = "$sapphire";
          "col.inactive" = "$surface0";
        };
      };

      decoration = {
        rounding = 5;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };

        shadow.enabled = false;
      };

      animations = {
        enabled = true;
        bezier = [
          "windows, 0.05, 0.9, 0.1, 1.05"
          "linear, 1, 1, 1, 1"
        ];

        animation = [
          "workspaces, 1, 2, default"
          "windows, 1, 3, windows, slide"
          "border, 1, 1, linear"
          "borderangle, 1, 30, linear, loop"
          "fade, 1, 10, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      gestures = {
        workspace_swipe = false;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        allow_session_lock_restore = true;
        enable_swallow = true;
        swallow_regex = ".*kitty$";
        swallow_exception_regex = ".*noswallow.*";
        vrr = 2;
      };

      render = {
        direct_scanout = true;
      };

      windowrulev2 =
        [
          "suppressevent maximize, class:.*"
          "size 500 700, class:com.github.hluk.copyq"
          # Chrome screen sharing popups
          "move 67% 100%-70, title:is sharing a window.$"
          "move 67% 100%-70, title:is sharing your screen.$"
          # VSCode confirmation popups
          "stayfocused, class:code, floating:1"
          "noborder, class:code, floating:1"

          # "stayfocused,class:^(jetbrains-.*)$,title:^$,floating:1"
          "noborder,class:^(jetbrains-.*)$,title:^$,floating:1"
        ]
        ++ (builtins.concatMap (class: [
            "float, class:${class}"
            "center 1, class:${class}"
          ]) [
            "com.github.hluk.copyq"
            ".blueman-manager-wrapped"
            "pavucontrol"
            "org.fcitx."
          ]);

      layerrule = [
        # tofi
        "noanim, launcher"
      ];

      bind = let
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
        resize = binding "SUPER ALT" "resizeactive";
      in
        [
          "SUPER, Return, exec, kitty"
          "SUPER, M, exit,"
          "SUPER, E, exec, thunar"
          "SUPER, D, exec, tofi-drun --drun-launch=true"
          "CTRL SHIFT, D, exec, copyq toggle"
          "SUPER SHIFT, A, exec, ${yubikey-totp}"

          "SUPER, Escape, exec, loginctl lock-session"

          # Screenshots
          "SUPER, S, exec, foxshot"
          "SUPER SHIFT, S, exec, sleep 3 && foxshot"
          "SUPER CTRL, S, exec, foxshot edit"
          "SUPER, O, exec, hyprpicker --autocopy --render-inactive"

          # Misc window management
          "SUPER SHIFT, Q, killactive,"
          "SUPER SHIFT, Space, togglefloating,"
          "SUPER, J, togglesplit,"
          "SUPER, P, pin"
          "SUPER, F, fullscreen, 0"

          # Resize window
          (resize "left" "-20 0")
          (resize "right" "20 0")
          (resize "up" "0 20")
          (resize "down" "0 -20")

          # Grouping
          "SUPER, G, togglegroup,"
          "SUPER, Tab, changegroupactive, f"
          "SUPER SHIFT, Tab, changegroupactive, b"

          "SUPER, mouse_down, split-workspace, e-1"
          "SUPER, mouse_up, split-workspace, e+1"

          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

          # ", XF86WakeUp, exec, ${switch-layout}"
        ]
        ++ (builtins.concatMap (x: let
          arg = builtins.substring 0 1 x;
        in [
          (binding "SUPER" "movefocus" x arg)
          (binding "SUPER SHIFT" "swapwindow" x arg)
          (binding "SUPER CTRL" "moveintogroup" x arg)
          (binding "SUPER CTRL SHIFT" "moveoutofgroup" x arg)
        ]) ["left" "right" "up" "down"])
        ++ (builtins.concatMap (i: [
          (binding "SUPER" "split-workspace" i i)
          (binding "SUPER SHIFT" "split-movetoworkspace" i i)
        ]) (map toString [1 2 3 4 5 6 7 8 9]));

      bindl = [
        "SUPER SHIFT, Pause, exec, systemctl suspend"
        "SUPER SHIFT, F5, exec, hyprctl dispatch dpms off && hyprctl dispatch dpms on"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl pause"
        ", XF86AudioStop, exec, playerctl pause"
        ", XF86AudioPlayPause, exec, playerctl play-pause"
        ", XF86PickupPhone, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86HangupPhone, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86NotificationCenter, exec, playerctl previous"
      ];

      bindle = [
        ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"

        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
}
