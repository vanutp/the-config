{
  pkgs,
  hyprland,
}:
pkgs.stdenv.mkDerivation {
  pname = "split-monitor-workspaces";
  version = "0.1";
  src = pkgs.fetchFromGitHub {
    owner = "Duckonaut";
    repo = "split-monitor-workspaces";
    rev = "131bc5bd02d7f558a66d1a6c4d0013d8545823e0";
    hash = "sha256-T9NTy1oGLv4FGHXK501OS6bSDfvAsyIGuoiJBAo+3IU=";
  };

  # allow overriding xwayland support
  BUILT_WITH_NOXWAYLAND = false;

  nativeBuildInputs = with pkgs; [meson ninja pkg-config];

  buildInputs =
    [
      hyprland.dev
      pkgs.pango
      pkgs.cairo
    ]
    ++ hyprland.buildInputs;

  meta = with pkgs.lib; {
    homepage = "https://github.com/Duckonaut/split-monitor-workspaces";
    description = "A small Hyprland plugin to provide awesome-like workspace behavior";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
