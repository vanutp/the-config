{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs;
    [
      pkgs-unstable.zed-editor
      (
        inputs.fjord.packages.${pkgs.system}.fjordlauncher.override {
          # https://github.com/PrismLauncher/PrismLauncher/blob/e777201187a6bceeb7d3b14dbf9a9369963ebcd1/CMakeLists.txt#L243
          msaClientID = "c36a9fb6-4f2a-41ff-90bd-ae7cc92031eb";
        }
      )
      xournalpp
      slack
      webcord
      obs-studio
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
