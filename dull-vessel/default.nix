{hyprland, ...}: {
  systemType = "x86_64-linux";
  overlays = [
    hyprland.overlays.default
    (self: super: {
      mpv-unwrapped = super.mpv-unwrapped.override {
        ffmpeg = super.ffmpeg-full;
      };
    })
  ];
  hmMode = "modular";
  system = ./system;
  users = {
    fox = ./home;
    root = ./root;
  };
}
