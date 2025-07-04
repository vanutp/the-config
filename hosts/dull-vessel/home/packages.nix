{
  pkgs,
  inputs,
  ...
}: {
  services.syncthing.enable = true;

  home.packages = with pkgs; [
    # cli
    openssl
    lm_sensors
    yt-dlp
    xh
    ffmpeg-full
    manix
    imagemagick
    yubikey-manager
    vim.xxd
    dig
    backblaze-b2
    ltrace
    minio-client

    # de
    xorg.xhost
    wev
    wl-clipboard
    (import ./foxshot pkgs)
    brightnessctl
    playerctl
    copyq
    pavucontrol
  ];
}
