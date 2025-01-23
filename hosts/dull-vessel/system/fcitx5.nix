{pkgs-unstable, ...}: {
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      addons = [
        pkgs-unstable.fcitx5-mozc
      ];
      waylandFrontend = true;
    };
  };
}
