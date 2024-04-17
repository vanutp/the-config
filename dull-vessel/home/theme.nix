{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

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
  };

  config = {
    gtk = {
      enable = true;

      theme = {
        package = pkgs.gnome.gnome-themes-extra;
        name = "Adwaita-dark";
      };

      iconTheme = {
        package = pkgs.gnome.adwaita-icon-theme;
        name = "Adwaita-dark";
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    qt = {
      enable = true;
      platformTheme = "kde";
      style.name = "breeze";
      style.package = pkgs.kdePackages.breeze;
    };

    catppuccin.flavour = "mocha";

    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      fira
      (fira-math.overrideAttrs (_: {
        nativeBuildInputs = [
          (python3.withPackages (ps:
            with ps; [
              (fontmake.overridePythonAttrs (_: {
                doCheck = false;
              }))
              fonttools
              glyphslib
              toml
            ]))
        ];
      }))
      (nerdfonts.override {
        fonts = ["FiraCode" "JetBrainsMono"];
      })
    ];
  };
}
