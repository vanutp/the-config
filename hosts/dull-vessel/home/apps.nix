{
  pkgs,
  pkgs-unstable,
  self-pkgs,
  ...
}: {
  home.packages = with pkgs;
    [
      (pkgs-unstable.anki-bin.overrideAttrs (prev: {
        nativeBuildInputs = (prev.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
        buildCommand =
          (prev.buildCommand or "")
          + ''
            wrapProgram $out/bin/anki-bin \
              --set ANKI_WAYLAND 1
          '';
      }))
      sidequest
      loupe
      xournalpp
      slack
      vesktop
      (wrapOBS {
        plugins = [obs-studio-plugins.wlrobs];
      })
      okular
      libreoffice-fresh
      pkgs-unstable.gimp3
      (mpv.override {
        scripts = [mpvScripts.mpris];
      })
      via
      ark
      spotify
      (google-chrome.override {
        commandLineArgs = ["--enable-wayland-ime" "--wayland-text-input-version=3"];
      })
      firefox
      corefonts
      vistafonts
      (pkgs.makeDesktopItem {
        name = "telegram-1";
        desktopName = "Telegram 1";
        exec = "64gram -workdir /home/fox/.local/share/telegram-1";
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
      obsidian
      nautilus
    ]
    ++ (with self-pkgs; [
      veyon
      _64gram
    ]);
}
