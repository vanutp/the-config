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
            -Dsun.java2d.uiScale=1
          '';
        };
      })
      ["IntelliJIdea2024.1/idea64.vmoptions" "CLion2024.1/clion64.vmoptions"]
    )
    // {
      ".config/JetBrains/IntelliJIdea2024.2/idea64.vmoptions".text = ''
        -Xmx4096m
        -Dawt.toolkit.name=WLToolkit
      '';
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
    nil
    alejandra
    vscode
    (pkgs-unstable.jetbrains.idea-ultimate.overrideAttrs {
      src = fetchurl {
        url = "https://download.jetbrains.com/idea/ideaIU-2024.2.0.2.tar.gz";
        hash = "sha256-zyFZueph6pENJ60OZhzdk1dfZc20Q/mb0VYA9ZYLf0s=";
      };
    })
    jetbrains.clion
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
  ];
}
