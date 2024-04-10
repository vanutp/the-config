{
  overlays = {hyprland, ...}: [
    hyprland.overlays.default
    (self: super: {
      mpv-unwrapped = super.mpv-unwrapped.override {
        ffmpeg = super.ffmpeg-full;
      };
      fprintd = super.fprintd.overrideAttrs {
        mesonCheckFlags = [
          # https://github.com/NixOS/nixpkgs/pull/298491
          # not in nixos-unstable yet
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
