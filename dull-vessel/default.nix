{hyprland, ...}: {
  systemType = "x86_64-linux";
  overlays = [
    hyprland.overlays.default
    (self: super: {
      mpv-unwrapped = super.mpv-unwrapped.override {
        ffmpeg = super.ffmpeg-full;
      };
      fprintd = super.fprintd.overrideAttrs {
        mesonCheckFlags = [
          # PAM related checks are timing out
          "--no-suite"
          "fprintd:TestPamFprintd"
          "--no-suite"
          "fprintd:daemon+fprintd+FPrintdVirtualDeviceStorageVerificationTests"
        ];
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
