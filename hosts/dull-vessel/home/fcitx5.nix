# the default hm module sets variables that shouldn't be set on wayland
{pkgs, ...}: let
  pkg = pkgs.qt6Packages.fcitx5-with-addons.override {
    addons = [
      pkgs.fcitx5-mozc
    ];
  };
  gtk2Cache =
    pkgs.runCommandLocal "gtk2-immodule.cache" {
      buildInputs = [pkgs.gtk2 pkg];
    } ''
      mkdir -p $out/etc/gtk-2.0/
      GTK_PATH=${pkg}/lib/gtk-2.0/ \
        gtk-query-immodules-2.0 > $out/etc/gtk-2.0/immodules.cache
    '';
  gtk3Cache =
    pkgs.runCommandLocal "gtk3-immodule.cache" {
      buildInputs = [pkgs.gtk3 pkg];
    } ''
      mkdir -p $out/etc/gtk-3.0/
      GTK_PATH=${pkg}/lib/gtk-3.0/ \
        gtk-query-immodules-3.0 > $out/etc/gtk-3.0/immodules.cache
    '';
in {
  home.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    QT_PLUGIN_PATH = "$QT_PLUGIN_PATH\${QT_PLUGIN_PATH:+:}${pkg}/${pkgs.qt6.qtbase.qtPluginPrefix}";
  };
  home.packages = [
    pkg
    gtk2Cache
    gtk3Cache
  ];
  systemd.user.sessionServices = [
    {
      package = pkg;
      binary = "/bin/fcitx5";
    }
  ];
}
