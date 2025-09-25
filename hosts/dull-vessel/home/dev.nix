{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.file =
    builtins.listToAttrs (
      map
      (vmoptionsPath: {
        name = ".config/JetBrains/${vmoptionsPath}";
        value = {
          text = ''
            -Xmx4096m
            -Dawt.toolkit.name=WLToolkit
            -Didea.kotlin.plugin.use.k2=true
          '';
        };
      })
      [
        "IntelliJIdea2025.1/idea64.vmoptions"
        "CLion2025.1/clion64.vmoptions"
        "PyCharm2025.1/pycharm64.vmoptions"
      ]
    )
    // {
      ".local/share/jdks/temurin17".source = pkgs.temurin-bin-17;
      ".local/share/jdks/temurin21".source = pkgs.temurin-bin-21;
    };

  programs.zsh.completionInit = ''
    if [[ $(stat -c '%U' /nix) = nobody ]]; then
      # running in distrobox
      autoload -U compinit && compinit -u
    else
      autoload -U compinit && compinit
    fi
  '';

  programs.zsh.sessionVariables = {
    UV_PYTHON_PREFERENCE = "only-system";
    UV_PYTHON = pkgs.python3;
  };

  home.packages = with pkgs; [
    lorem
    tokei
    hyperfine
    gtk4
    temurin-bin-21 # default java
    nodejs
    corepack
    deno
    rustup
    (python3.withPackages (
      ps:
        with ps;
          [
            black
            dbus-python
            ipython
            httpx
          ]
          ++ black.optional-dependencies.d
    ))
    (poetry.withPlugins (ps: with ps; [poetry-plugin-export]))
    pkgs-unstable.uv
    pkgs-unstable.ruff
    pipenv
    twine
    pgcli
    gnumake
    clang
    gdb
    lldb_19
    nixd
    (stdenv.mkDerivation {
      name = "nixd-with-semantic";
      nativeBuildInputs = [pkgs.makeWrapper];
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/bin
        makeWrapper ${pkgs.nixd}/bin/nixd $out/bin/nixd-with-semantic \
          --add-flags "--semantic-tokens=true"
      '';
    })
    alejandra
    pkgs-unstable.zed-editor
    pkgs-unstable.vscode
    pkgs-unstable.jetbrains.idea-ultimate
    pkgs-unstable.jetbrains.idea-community-bin
    # pkgs-unstable.jetbrains.pycharm-professional
    # pkgs-unstable.jetbrains.clion
    # pkgs-unstable.jetbrains-toolbox
    # (
    #   pkgs.android-studio.withSdk
    #   (pkgs.androidenv.composeAndroidPackages {
    #     platformVersions = ["34"];
    #     includeEmulator = false;
    #     includeSystemImages = false;
    #     includeNDK = false;
    #   })
    #   .androidsdk
    # )
    pre-commit
    kubectl
    kubelogin-oidc
    kubernetes-helm
  ];
}
