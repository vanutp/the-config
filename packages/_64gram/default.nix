pkgs: let
  pname = "64gram";
  version = "1.1.50";
  binary = pkgs.stdenv.mkDerivation {
    pname = "${pname}-bin";
    inherit version;
    src = pkgs.fetchzip {
      url = "https://github.com/TDesktop-x64/tdesktop/releases/download/v${version}/64Gram_${version}_linux.zip";
      hash = "sha256-iQWJ/jdbGBupG585aprfrOXWgoN3bvFYr/52GSeM8AE=";
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
