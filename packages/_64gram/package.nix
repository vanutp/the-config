pkgs: let
  pname = "64gram";
  version = "1.1.79";
  binary = pkgs.stdenv.mkDerivation {
    pname = "${pname}-bin";
    inherit version;
    src = pkgs.fetchzip {
      url = "https://github.com/TDesktop-x64/tdesktop/releases/download/v${version}/64Gram_${version}_linux.zip";
      hash = "sha256-OIY6IB5eOxnRXfHrVI61qD1Wyz0NzXkJJaHC2Ama1jk=";
      stripRoot = false;
    };
    buildPhase = ''
      mkdir $out
      cp Telegram $out
    '';
  };
in (
  pkgs.buildFHSEnv (
    pkgs.appimageTools.defaultFhsEnvArgs
    // {
      inherit pname version;
      targetPkgs = pkgs: (with pkgs; [
        gtk3
        webkitgtk_4_1
        glib-networking
      ]);
      runScript = pkgs.writeShellScript "64gram-wrapper" ''
        export GIO_MODULE_DIR=/usr/lib/gio/modules/
        export QT_WAYLAND_DISABLED_INTERFACES=wp_fractional_scale_manager_v1
        exec ${binary}/Telegram "$@"
      '';
    }
  )
)
