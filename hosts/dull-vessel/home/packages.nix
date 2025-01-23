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
    inputs.manix.packages.${pkgs.system}.manix
    imagemagick
    yubikey-manager
    vim.xxd
    distrobox
    bubblewrap
    dig
    backblaze-b2
    ltrace
    minio-client

    # de
    xorg.xhost
    kdePackages.polkit-kde-agent-1
    wev
    wl-clipboard
    (import ./foxshot pkgs)
    brightnessctl
    playerctl
    copyq
    hyprpaper
    hyprpicker
    pavucontrol
    # needed for thunar and other xfce apps to be able to save settings
    xfce.xfconf
  ];
}
