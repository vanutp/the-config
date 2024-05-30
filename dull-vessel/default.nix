{
  overlays = {hyprland, ...}: [
    hyprland.overlays.default
    (self: super: {
      mpv-unwrapped = super.mpv-unwrapped.override {
        ffmpeg = super.ffmpeg-full;
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
