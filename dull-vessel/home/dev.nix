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
      ["IntelliJIdea2024.2/idea64.vmoptions" "CLion2024.2/clion64.vmoptions"]
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
    pipenv
    twine
    pgcli
    gnumake
    clang
    gdb
    lldb
    nil
    alejandra
    vscode
    pkgs-unstable.jetbrains.idea-ultimate
    pkgs-unstable.jetbrains.clion
    (
      pkgs-unstable.android-studio.withSdk
      (pkgs-unstable.androidenv.composeAndroidPackages {
        platformVersions = ["34"];
        includeEmulator = true;
        includeSystemImages = true;
        includeNDK = true;
      })
      .androidsdk
    )
    (with dotnetCorePackages;
      combinePackages [
        sdk_6_0
        sdk_7_0
        sdk_8_0
      ])
    nuget
    pre-commit
    kubectl
    kubelogin-oidc
    kubernetes-helm
    (pkgs-unstable.haskellPackages.ghcWithPackages (pkgs: with pkgs; [stack]))
    pkgs-unstable.haskell-language-server
  ];
}
