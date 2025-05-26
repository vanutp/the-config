{
  config,
  pkgs,
  lib,
  ...
}: {
  options = with lib; {
    preferences.wallpaper = mkOption {
      type = types.path;
      description = "Path to wallpaper file.";
      default = ./wallpapers/poly-comets.png;
    };
    preferences.font.monospace = mkOption {
      type = types.str;
      description = "Default monospace font name";
      default = "JetBrainsMono Nerd Font";
    };
    preferences.font.monospace-path = mkOption {
      type = types.str;
      description = "Default monospace font path";
      default = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf";
    };
  };

  config = {
    gtk = {
      enable = true;

      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    qt = {
      enable = true;
      platformTheme.name = "qtct";
    };

    fonts.fontconfig.enable = true;
    fonts.fontconfig.defaultFonts.sansSerif = ["Noto Sans"];
    fonts.fontconfig.defaultFonts.serif = ["Noto Serif"];
    fonts.fontconfig.defaultFonts.monospace = [config.preferences.font.monospace];
    fonts.fontconfig.defaultFonts.emoji = ["Noto Color Emoji"];

    home.packages = with pkgs; [
      pkgs.gnome-themes-extra
      libsForQt5.qtstyleplugin-kvantum
      qt6Packages.qtstyleplugin-kvantum
      kdePackages.breeze
      kdePackages.breeze-icons
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      fira
      fira-math
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };
}
