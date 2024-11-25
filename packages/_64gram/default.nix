pkgs: let
  pname = "64gram";
  version = "1.1.49";
  binary = pkgs.stdenv.mkDerivation {
    pname = "${pname}-bin";
    inherit version;
    src = pkgs.fetchzip {
      url = "https://github.com/TDesktop-x64/tdesktop/releases/download/v${version}/64Gram_${version}_linux.zip";
      hash = "sha256-+6ujHPz0QYmjKh6P0LpiJHKv6UvxibKsQ8NNWobReMo=";
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
        exec ${binary}/Telegram "$@"
      '';
    }
  )
)
