{...}: {
  home.file = builtins.listToAttrs (
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
    ["IntelliJIdea2023.3/idea64.vmoptions" "CLion2023.3/clion64.vmoptions"]
  );
}
