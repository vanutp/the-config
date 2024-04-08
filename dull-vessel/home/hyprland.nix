{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

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

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = ["--all"];
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
    ];
    catppuccin.enable = true;
    settings = {
      monitor = [
        "eDP-1,1920x1200@60,0x0,1.25"
        "DP-1,1920x1080@60,1536x0,1.25"
        "HDMI-A-1,1920x1080@60,1536x0,1.25"
      ];

      xwayland.force_zero_scaling = true;

      exec-once = [
        "hyprpaper"
        "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
        "copyq --start-server"
        "playerctld daemon"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "GTK_USE_PORTAL,1" # make gtk applications use portal instead of builtin gtk file picker
        "NIXOS_OZONE_WL,1"
        "NIX_LD_LIBRARY_PATH,${pkgs.stdenv.cc.cc.lib}/lib"
      ];

      input = {
        kb_layout = "de,ru";
        kb_variant = "us,";
        kb_options = "grp:caps_toggle";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = false;
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

        drop_shadow = false;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
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

      master = {
        new_is_master = true;
      };

      gestures = {
        workspace_swipe = false;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        allow_session_lock_restore = true;
        enable_swallow = true;
        swallow_regex = ".*wezterm$";
        swallow_exception_regex = ".*noswallow.*";
        no_direct_scanout = false;
        vrr = 2;
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

          # IntelliJ fixes
          # based on https://github.com/hyprwm/Hyprland/issues/3450#issuecomment-1816761575

          # idk what exactly it fixes
          "windowdance,class:^(jetbrains-.*)$,floating:1"
          # Fix splash screen showing in weird places and prevent annoying focus takeovers
          "center,class:^(jetbrains-.*)$,title:^(splash)$,floating:1"
          "nofocus,class:^(jetbrains-.*)$,title:^(splash)$,floating:1"
          "noborder,class:^(jetbrains-.*)$,title:^(splash)$,floating:1"
          # Center popups/find windows
          "center,class:^(jetbrains-.*)$,title:^( )$,floating:1"
          "stayfocused,class:^(jetbrains-.*)$,title:^( )$,floating:1"
          "noborder,class:^(jetbrains-.*)$,title:^( )$,floating:1"
          # Fix tooltips and popups. The most important rule
          "nofocus,class:^(jetbrains-.*)$,title:^(win.*)$,floating:1"
        ]
        ++ (builtins.concatMap (class: [
            "float, class:${class}"
            "center 1, class:${class}"
          ]) [
            "com.github.hluk.copyq"
            ".blueman-manager-wrapped"
            "pavucontrol"
          ]);

      bind = let
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
        resize = binding "SUPER ALT" "resizeactive";
      in
        [
          "SUPER, Return, exec, wezterm"
          "SUPER, M, exit,"
          "SUPER, E, exec, thunar"
          "SUPER, D, exec, wofi -S drun"
          "CTRL SHIFT, D, exec, copyq toggle"
          "SUPER SHIFT, A, exec, /home/fox/bin/yubikey-totp-wayland.sh"

          "SUPER, Escape, exec, loginctl lock-session"

          "SUPER, grave, hyprexpo:expo, toggle"

          # Screenshots
          "SUPER, S, exec, grimblast --freeze copy area"
          "SUPER SHIFT, S, exec, sleep 3 && grimblast --freeze copy area"
          "SUPER CTRL, S, exec, GRIMBLAST_EDITOR=\"satty --copy-command wl-copy --filename\" grimblast --freeze edit area"

          # Misc window management
          "SUPER SHIFT, Q, killactive,"
          "SUPER SHIFT, Space, togglefloating,"
          "SUPER, J, togglesplit,"
          "SUPER, P, pin"

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
      ];

      bindle = [
        ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"

        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl pause"
        ", XF86AudioStop, exec, playerctl pause"
        ", XF86AudioPlayPause, exec, playerctl play-pause"
        ", XF86Go, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", Cancel, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86Messenger, exec, playerctl previous"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
}
