{pkgs, ...}: {
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
      ".local/share/jdks/temurin8".source = pkgs.temurin-bin-8;
      ".local/share/jdks/temurin17".source = pkgs.temurin-bin-17;
    };

  home.packages = with pkgs; [
    hyperfine
    gtk4
    temurin-bin-17 # default java
    nodejs
    yarn
    rustup
    (python3.withPackages (
      ps:
        with ps;
          [
            black
            dbus-python
          ]
          ++ black.optional-dependencies.d
    ))
    (poetry.withPlugins (ps: with ps; [poetry-plugin-export]))
    pipenv
    python3Packages.ipython
    twine
    pgcli
    gnumake
    clang
    nil
    alejandra
    vscode
    jetbrains.gateway
    jetbrains.idea-ultimate
    # remove when https://github.com/NixOS/nixpkgs/pull/304223 is merged
    (jetbrains.clion.overrideAttrs (orig: {
      buildInputs =
        orig.buildInputs
        ++ [
          pkgs.fontconfig
          pkgs.lttng-ust_2_12
        ];
    }))
    (with dotnetCorePackages;
      combinePackages [
        sdk_7_0
        sdk_8_0
      ])
    nuget
    pre-commit
  ];
}
