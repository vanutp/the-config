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
}
