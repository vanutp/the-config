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
      platformTheme.name = "kde6";
      style.name = "breeze";
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = ["Noto Sans"];
        serif = ["Noto Serif"];
        monospace = [config.preferences.font.monospace];
        emoji = ["Noto Color Emoji"];
      };
    };

    # костылирование для зена во флатпаке
    systemd.user.tmpfiles.rules = [
      "L ${config.xdg.dataHome}/fonts - - - - ${config.xdg.stateHome}/nix/profiles/profile/share/fonts"
    ];

    home.packages = with pkgs; [
      pkgs.gnome-themes-extra
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
