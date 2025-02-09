{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    ghostty
  ];
  # from the unstable home-manager module
  xdg.configFile."ghostty/config" = let
    keyValue = pkgs.formats.keyValue {
      listsAsDuplicateKeys = true;
      mkKeyValue = lib.generators.mkKeyValueDefault {} " = ";
    };
  in {
    source = keyValue.generate "ghostty-config" {
      theme = "catppuccin-mocha";
      gtk-titlebar = false;
      window-padding-x = 5;
      window-padding-y = 3;
      font-family = config.preferences.font.monospace;
      mouse-scroll-multiplier = 3;
      gtk-single-instance = true;
    };
    onChange = "${lib.getExe pkgs.ghostty} +validate-config";
  };
}
