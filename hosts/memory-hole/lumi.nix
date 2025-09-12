{pkgs, ...}: {
  home.packages = with pkgs; [
    makemkv
    ffmpeg
    libfaketime
  ];
}
