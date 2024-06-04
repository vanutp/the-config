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

  home.packages = with pkgs; [
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
    vim.xxd
    distrobox
    bubblewrap
    dig

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
  ];
}
