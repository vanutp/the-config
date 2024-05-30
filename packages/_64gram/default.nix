pkgs @ {
  telegram-desktop,
  fetchFromGitHub,
  ...
}:
telegram-desktop.overrideAttrs (orig: rec {
  pname = "64gram";
  version = "1.1.24";
  src = fetchFromGitHub {
    owner = "TDesktop-x64";
    repo = "tdesktop";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-pAtV/uKWCh9sODCYXf6gM8B0i2o5OiVH7z2iLjIZKP0=";
  };

  buildInputs = let
    patched-qt = import ./patched-qt.nix pkgs;
    pnames = map (x: x.pname) patched-qt;
  in
    builtins.filter (p: !builtins.elem p.pname pnames) orig.buildInputs
    ++ patched-qt;

  cmakeFlags = [
    "-Ddisable_autoupdate=ON"
    # 64gram
    "-DTDESKTOP_API_ID=611335"
    "-DTDESKTOP_API_HASH=d524b414d21f4d37f08684c1df41ac9c"

    "-DDESKTOP_APP_USE_PACKAGED_FONTS=OFF"
    "-DDESKTOP_APP_DISABLE_SCUDO=ON"
  ];
})
