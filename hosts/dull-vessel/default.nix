{
  overlays = {...}: [
    (self: super: {
      mpv-unwrapped = super.mpv-unwrapped.override {
        ffmpeg = super.ffmpeg-full;
      };
    })
  ];
  system = ./system;
  users = {
    fox = ./home;
    root = {...}: {};
  };
}
