{
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
          '';
        };
      })
      ["IntelliJIdea2024.3/idea64.vmoptions" "CLion2024.3/clion64.vmoptions"]
    )
    // {
      ".local/share/jdks/temurin8".source = pkgs.temurin-bin-8;
      ".local/share/jdks/temurin11".source = pkgs.temurin-bin-11;
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

  home.packages = with pkgs; [
    hyperfine
    gtk4
    temurin-bin-21 # default java
    nodejs
    corepack
    pkgs.deno
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
    nil
    alejandra
    pkgs-unstable.zed-editor
    pkgs-unstable.vscode
    pkgs-unstable.jetbrains.idea-ultimate
    pkgs-unstable.jetbrains.clion
    pkgs-unstable.jetbrains-toolbox
    (
      pkgs.android-studio.withSdk
      (pkgs.androidenv.composeAndroidPackages {
        platformVersions = ["34"];
        includeEmulator = false;
        includeSystemImages = false;
        includeNDK = false;
      })
      .androidsdk
    )
    pre-commit
    kubectl
    kubelogin-oidc
    kubernetes-helm
  ];
}
