{
  overlays = {hyprland, ...}: [
    hyprland.overlays.default
    (self: super: {
      mpv-unwrapped = super.mpv-unwrapped.override {
        ffmpeg = super.ffmpeg-full;
      };
      fprintd = super.fprintd.overrideAttrs {
        # https://github.com/NixOS/nixpkgs/issues/299111
        # Disabling all tests for now2
        mesonCheckFlags = [
          "--no-suite"
          "fprintd"
        ];
      };
      python3 = super.python3.override {
        packageOverrides = python-self: python-super: {
          ufo2ft = python-super.ufo2ft.overrideAttrs rec {
            pname = "ufo2ft";
            version = "3.2.2";
            src = super.fetchPypi {
              inherit pname version;
              hash = "sha256-5HWhRxKs4KQdC1v0LaLgndgMwtcGKLVz9tYtesdJ8Oo=";
            };
          };
        };
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
