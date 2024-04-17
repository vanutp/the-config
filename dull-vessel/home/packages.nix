{
  pkgs,
  inputs,
  ...
}: {
  home.packages =
    (with pkgs; [
      # cli
      openssl
      lm_sensors
      yt-dlp
      httpie
      ffmpeg-full
      (ghostscriptX.overrideAttrs (old: {
        pname = "ghostpdl-with-X";

        src = fetchurl {
          url = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs${lib.replaceStrings ["."] [""] old.version}/ghostpdl-${old.version}.tar.xz";
          hash = "sha512-AXmiOUwkT7pubfLLU4d+OWi+zC6kl+AYuIIDKJ/rVJcm43LnFufNdKH2SLRmLqwnqerSH9V7n2NCgXC+cvnoEA==";
        };
      }))
      inputs.manix.packages.${pkgs.system}.manix
      imagemagick
      yubikey-manager

      # de
      xorg.xhost
      grim
      kdePackages.polkit-kde-agent-1
      wev
      wl-clipboard
      grimblast
      satty
      brightnessctl
      playerctl
      copyq
      hyprpaper
      hyprpicker
      pavucontrol
      wofi

      # dev
      gtk4
      temurin-bin-17
      nodejs
      yarn
      rustup
      (python3.withPackages (
        ps:
          with ps;
            [
              black
              dbus-python
            ]
            ++ black.optional-dependencies.d
      ))
      (poetry.withPlugins (ps: with ps; [poetry-plugin-export]))
      pipenv
      python3Packages.ipython
      twine
      pgcli
      gnumake
      clang
      nil
      alejandra
      vscode
      jetbrains.gateway
      jetbrains.idea-ultimate
      # remove when https://github.com/NixOS/nixpkgs/pull/304223 is merged
      (jetbrains.clion.overrideAttrs (orig: {
        buildInputs =
          orig.buildInputs
          ++ [
            pkgs.fontconfig
            pkgs.lttng-ust_2_12
          ];
      }))
      (with dotnetCorePackages;
        combinePackages [
          sdk_7_0
          sdk_8_0
        ])
      nuget
      pre-commit

      # desktop
      prismlauncher
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
    ])
    ++ (with inputs.self.packages.${pkgs.system}; [
      veyon
      _64gram
    ]);
}
