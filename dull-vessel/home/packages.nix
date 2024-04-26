{
  pkgs,
  inputs,
  ...
}: {
  services.syncthing.enable = true;
  programs.spotify-player = {
    enable = true;
    settings = {
      enable_notify = false;
      cover_img_length = 13;
      cover_img_width = 6;
      playback_window_position = "Bottom";
      device = {
        volume = 100;
      };
    };
    keymaps = [
      {
        command = "None";
        key_sequence = "q";
      }
      {
        command = "Quit";
        key_sequence = "C-q";
      }
    ];
  };

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

      # desktop
      (
        let
          pollymc-unwrapped = prismlauncher-unwrapped.overrideAttrs (old: rec {
            pname = "pollymc-unwrapped";
            version = "8.0";
            src = fetchFromGitHub {
              owner = "fn2006";
              repo = "PollyMC";
              rev = version;
              hash = "sha256-DF1lxQHetDKZEpRrRZ0HQWqqMDAGNiTZoCJUARdXFSk=";
            };
            meta.mainProgram = "pollymc";
          });
        in
          (prismlauncher.overrideAttrs {
            name = "pollymc-${pollymc-unwrapped.version}";
          })
          .override {
            prismlauncher-unwrapped = pollymc-unwrapped;
            # https://github.com/PrismLauncher/PrismLauncher/blob/e777201187a6bceeb7d3b14dbf9a9369963ebcd1/CMakeLists.txt#L243
            msaClientID = "c36a9fb6-4f2a-41ff-90bd-ae7cc92031eb";
          }
      )
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
    ])
    ++ (with inputs.self.packages.${pkgs.system}; [
      veyon
      _64gram
    ]);
}
