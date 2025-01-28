{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.kitty = {
    enable = true;
    font.name = config.preferences.font.monospace;
    font.size = 12;
    themeFile = "Catppuccin-Mocha";
    settings = {
      scrollback_lines = 10000;
      background_opacity = "0.8";
      enable_audio_bell = false;
      window_padding_width = "3 5";
      touch_scroll_multiplier = "5.0";
    };
  };

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
    };
    onChange = "${lib.getExe pkgs.ghostty} +validate-config";
  };
}
