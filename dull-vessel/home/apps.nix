{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.kitty = {
    enable = true;
    package = pkgs-unstable.kitty;
    font.name = config.preferences.font.monospace;
    font.size = 12;
    theme = "Catppuccin-Mocha";
    settings = {
      scrollback_lines = 10000;
      background_opacity = "0.8";
      enable_audio_bell = false;
      window_padding_width = "3 5";
    };
  };

  home.packages = with pkgs;
    [
      sidequest
      pkgs-unstable.zed-editor
      gwenview
      xournalpp
      slack
      webcord
      (wrapOBS {
        plugins = [obs-studio-plugins.wlrobs];
      })
      okular
      libreoffice-fresh
      thunderbird
      gimp
      (mpv.override {
        scripts = [mpvScripts.mpris];
      })
      vlc
      via
      xfce.thunar
      xfce.tumbler
      kdePackages.qtwayland
      kdePackages.dolphin
      libsForQt5.kamoso
      ark
      spotify
      google-chrome
      firefox
      corefonts
      vistafonts
      (pkgs.makeDesktopItem {
        name = "telegram-1";
        desktopName = "Telegram 1";
        exec = "telegram-desktop -workdir /home/fox/.local/share/telegram-1";
        icon = "io.github.tdesktop_x64.TDesktop";
        terminal = false;
        startupWMClass = "64Gram";
        categories = ["Chat" "Network" "InstantMessaging" "Qt"];
        mimeTypes = ["x-scheme-handler/tg"];
        keywords = ["tg" "chat" "im" "messaging" "messenger" "sms" "tdesktop"];
        extraConfig = {
          SingleMainWindow = "true";
          X-GNOME-UsesNotifications = "true";
          X-GNOME-SingleWindow = "true";
        };
      })
      (obsidian.overrideAttrs {
        meta.priority = 10;
      })
      (pkgs.makeDesktopItem {
        name = "obsidian";
        desktopName = "Obsidian";
        comment = "Knowledge base";
        exec = "bash -c \"unset NIXOS_OZONE_WL && exec obsidian\"";
        icon = "obsidian";
        categories = ["Office"];
        mimeTypes = ["x-scheme-handler/obsidian"];
      })
    ]
    ++ (with inputs.self.packages.${pkgs.system}; [
      veyon
      # TODO: disable
      (enableDebugging _64gram)
    ]);
}
