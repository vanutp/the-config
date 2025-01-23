# See https://github.com/NixOS/nixpkgs/pull/259236
pkgs @ {
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}: let
  version = "4.8.3";

  contributors = pkgs.writeText "veyon-CONTRIBUTORS" ''
    Tobias Junghans
    For more see: https://github.com/veyon/veyon/contributors
  '';
in
  stdenv.mkDerivation {
    pname = "veyon";
    inherit version;

    src = fetchFromGitHub {
      owner = "veyon";
      repo = "veyon";
      rev = "v${version}";
      hash = "sha256-DubIQTh6i+ugCLxdpWN+xUeXrgmjYdAODM4imJDBpmk=";
      fetchSubmodules = true; # kldap, x11vnc and qthttpserver get built from source
    };

    patches = [./fix-install-perms.patch];

    nativeBuildInputs = with pkgs; [cmake pkg-config libsForQt5.wrapQtAppsHook];

    cmakeFlags = [
      # cmake's setup hook makes it so that this is absolute by default
      # veyon's build steps only work if this is relative
      "-DCMAKE_INSTALL_LIBDIR=lib"
      "-DWITH_PCH=OFF"
      "-DSYSTEMD_SERVICE_INSTALL_DIR=lib/systemd/system"
      "-DCONTRIBUTORS=${contributors}"
    ];

    buildInputs = with pkgs; [
      libsForQt5.qt5.qttools
      libsForQt5.qca
      lzo
      openldap
      cyrus_sasl
      pam
      procps
      xorg.libXtst
      xorg.libXrandr
      xorg.libXinerama
      xorg.libXdamage
      xorg.libXcursor
      libvncserver
      libfakekey
    ];

    # Some executables need to access the other ones
    qtWrapperArgs = ["--prefix PATH : ${placeholder "out"}/bin"];

    meta = {
      changelog = "https://github.com/veyon/veyon/releases/tag/v${version}";
      description = "A free and open source software for monitoring and controlling computers across multiple platforms";
      homepage = "https://veyon.io";
      license = lib.licenses.gpl2Only;
      mainProgram = "veyon-master";
      maintainers = with lib.maintainers; [tomasajt];
      platforms = lib.platforms.linux;
    };
  }
