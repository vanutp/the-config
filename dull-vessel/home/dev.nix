{...}: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Ivan Filipenkov";
    userEmail = "hello@vanutp.dev";
  };

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
