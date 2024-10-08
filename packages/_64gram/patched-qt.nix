# Generated by update-qt.py
# Do not modify
pkgs: let
  repository = pkgs.fetchFromGitHub {
    owner = "desktop-app";
    repo = "patches";
    rev = "85a1c4ec327ed390a27e85f2162c31525220a50d";
    hash = "sha256-F8l7BbJ8mFyG6ZxZu6Yf41jy6Z/oj818fjmzxv3fKys=";
  };
  qtbase = pkgs.kdePackages.qtbase.overrideAttrs (orig: {
    patches =
      orig.patches
      ++ [
        "${repository}/qtbase_6.7.2/0001-spellcheck-underline-from-chrome.patch"
        "${repository}/qtbase_6.7.2/0002-improve-apostrophe-processing.patch"
        "${repository}/qtbase_6.7.2/0003-allow-creating-floating-panels-macos.patch"
        "${repository}/qtbase_6.7.2/0004-fix-file-dialog-on-windows.patch"
        "${repository}/qtbase_6.7.2/0005-fix-launching-mail-program-on-windows.patch"
        "${repository}/qtbase_6.7.2/0006-save-dirtyopaquechildren.patch"
        "${repository}/qtbase_6.7.2/0007-always-use-xft-font-conf.patch"
        "${repository}/qtbase_6.7.2/0008-catch-cocoa-dock-menu.patch"
        "${repository}/qtbase_6.7.2/0009-fix-race-in-windows-timers.patch"
        "${repository}/qtbase_6.7.2/0010-nicer-platformtheme-choosing.patch"
        "${repository}/qtbase_6.7.2/0011-reset-current-context-on-error.patch"
        "${repository}/qtbase_6.7.2/0012-reset-opengl-widget-on-context-loss.patch"
        "${repository}/qtbase_6.7.2/0013-no-jpeg-chroma-subsampling.patch"
        "${repository}/qtbase_6.7.2/0014-convert-qimage-to-srgb.patch"
        "${repository}/qtbase_6.7.2/0015-lcms2.patch"
        "${repository}/qtbase_6.7.2/0016-better-color-scheme-support.patch"
        "${repository}/qtbase_6.7.2/0017-translucent-captioned-window-on-windows.patch"
        "${repository}/qtbase_6.7.2/0018-allow-bordered-translucent-macos.patch"
        "${repository}/qtbase_6.7.2/0019-better-open-url-linux.patch"
        "${repository}/qtbase_6.7.2/0020-follow-highdpi-rounding-policy-for-platform-dpr.patch"
        "${repository}/qtbase_6.7.2/0021-let-platform-backing-store-scale-transparency-filling.patch"
        "${repository}/qtbase_6.7.2/0022-fix-backing-store-rhi-unneeded-copy.patch"
        "${repository}/qtbase_6.7.2/0023-fix-backing-store-opengl-subimage-unneeded-copy.patch"
        "${repository}/qtbase_6.7.2/0024-portal-proxy-resolver.patch"
        "${repository}/qtbase_6.7.2/0025-fix-focus-in-hidden-window.patch"
        "${repository}/qtbase_6.7.2/0026-fix-only-emoji-line.patch"
        "${repository}/qtbase_6.7.2/0027-fix-rtl-cursor-move-up.patch"
        "${repository}/qtbase_6.7.2/0028-xcb-provide-xkb-state.patch"
      ];
  });
  qtshadertools = pkgs.kdePackages.qtshadertools.override {inherit qtbase;};
  qtlanguageserver = pkgs.kdePackages.qtlanguageserver.override {inherit qtbase;};
  qtdeclarative = pkgs.kdePackages.qtdeclarative.override {inherit qtbase qtlanguageserver qtshadertools;};
in [
  qtbase
  (pkgs.kdePackages.qtsvg.override {inherit qtbase;})
  (pkgs.kdePackages.qtimageformats.override {inherit qtbase;})
  ((pkgs.kdePackages.qtwayland.overrideAttrs {
      patches = [
        "${repository}/qtwayland_6.7.2/0001-always-fractional-scale.patch"
        "${repository}/qtwayland_6.7.2/0002-scale-transparency-filling.patch"
        "${repository}/qtwayland_6.7.2/0003-fix-gtk4-embedding.patch"
        "${repository}/qtwayland_6.7.2/0004-QWaylandShmBackingStore-Preserve-buffer-contents-bet.patch"
        "${repository}/qtwayland_6.7.2/0005-avoid-needlessly-initiailizing-opengl.patch"
        "${repository}/qtwayland_6.7.2/0006-fix-media-viewer-on-gnome.patch"
        "${repository}/qtwayland_6.7.2/0007-owning-rhi-backing-store.patch"
        "${repository}/qtwayland_6.7.2/0008-fix-egl-compositor-shutdown.patch"
        "${repository}/qtwayland_6.7.2/0009-compositor-xkb-state-from-platform.patch"
      ];
    })
    .override {inherit qtbase qtdeclarative;})
]
