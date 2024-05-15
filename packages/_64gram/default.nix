pkgs @ {
  telegram-desktop,
  fetchFromGitHub,
  fetchpatch,
  ...
}:
telegram-desktop.overrideAttrs (orig: rec {
  pname = "64gram";
  version = "1.1.22";
  src = fetchFromGitHub {
    owner = "TDesktop-x64";
    repo = "tdesktop";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-Fhix+kCqUTr9qGMzDc2undxmhjmM6fPorZebeqXNHHE=";
  };

  buildInputs =
    builtins.filter (p: !builtins.elem p.pname ["qtbase" "qtwayland" "qtsvg" "qtimageformats"]) orig.buildInputs
    ++ (let
      qtbase = pkgs.kdePackages.qtbase.overrideAttrs (orig: {
        patches =
          orig.patches
          ++ [
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0001-spellcheck-underline-from-chrome.patch";
              hash = "sha256-yqcLibnFa6zkqqJ35iP+egOszMnddV8iRZ5QNFNnOlE=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0002-improve-apostrophe-processing.patch";
              hash = "sha256-tUZJQcPnAj65BDTqSsG6o4m+qexVXSOCzQ0kTINcn5A=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0003-fix-shortcuts-on-macos.patch";
              hash = "sha256-/Ebl8S5EdR/m/UntR7RL2spfptr+mZnG/xSdSN7Q+bs=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0004-allow-creating-floating-panels-macos.patch";
              hash = "sha256-aK6YoGPPWoj05hhvI0IWXkP+n9rm00N9Mx65xrZUfHw=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0005-fix-file-dialog-on-windows.patch";
              hash = "sha256-wSUfqmopndLRoIaoztMbBJwndJaZfDAZHTOlS9AItmY=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0006-fix-launching-mail-program-on-windows.patch";
              hash = "sha256-XE8ql/2ab2CCzEQ7IQZon5tn6fi3bMnWrllBtCvEfbI=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0007-save-dirtyopaquechildren.patch";
              hash = "sha256-/+XkOmqgK02TYPeora4QZzDCRalfg0/dLttd8O5mx0U=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0008-always-use-xft-font-conf.patch";
              hash = "sha256-UMWs2paLrN7Jg6T/zaBioATt/33IQ17qDxmXV7rX9ZU=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0009-catch-cocoa-dock-menu.patch";
              hash = "sha256-a6DYYZOn1hLyfdAUeQmPWxFq1Wc5R/bRH3BrPisJtDA=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0010-fix-race-in-windows-timers.patch";
              hash = "sha256-/cU4oKWhPcObgxvJPtAYF1DvfpABdJxsjdeMeHsTTeU=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0011-nicer-platformtheme-choosing.patch";
              hash = "sha256-5gMQP2h5zEDI1odWV5mXgobWXIu9LdE5EK1tu2lGxy4=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0012-reset-current-context-on-error.patch";
              hash = "sha256-uwQ6lN+TatDX3BVqifn5Eatex3R1lZXTfBXhNrw8R+s=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0013-reset-opengl-widget-on-context-loss.patch";
              hash = "sha256-faKtbQ/cJDJGTNanLo0wQaqOstN4aNMtLRGjXNVF7GA=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0014-no-jpeg-chroma-subsampling.patch";
              hash = "sha256-xZncV3QYNw/rclrzIrmEF+nZ26DhK5kMGG99psOiGiA=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0015-convert-qimage-to-srgb.patch";
              hash = "sha256-Z9oPkte+6Qj99AtS+oxLCn6ctFpWDoHWkSBKltsrAkk=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0016-lcms2.patch";
              hash = "sha256-xOl+Wjm22HHIUiV+JwHMWZ9U7XzMiTYPpvuHXDlkZVg=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0017-better-color-scheme-support.patch";
              hash = "sha256-wDzVMwPkwza8KYUSLb+O6/1vuhs9qqLzAOISiXIyZV8=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0018-translucent-captioned-window-on-windows.patch";
              hash = "sha256-0FwaH+QZCMIQOs0p6/mPxAWVRfv8TJTTz+P9fh9p/Sc=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0019-allow-bordered-translucent-macos.patch";
              hash = "sha256-by7FayzF3cR6YK/KNReP3j/4U9u17EuehWQ+8P1eBT0=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0020-better-open-url-linux.patch";
              hash = "sha256-0tGuNAHTFiZvWMxDpIGT9JDrbXZLKx7/R3vkyl2L250=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0021-follow-highdpi-rounding-policy-for-platform-dpr.patch";
              hash = "sha256-rFbfoD5w67MpKeeVKKRjLs0Tj+BcAF8EFPXxPgy9tBs=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0022-highdpi-downscale-property.patch";
              hash = "sha256-uAuftoOGA+Fy06KNgFE3cjS1zBTeyEadLyieYRvsoZQ=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0023-highdpi-downscale-wayland.patch";
              hash = "sha256-ZEW+aLPUvlrHuU3B14VppRZZKctEeLYaIFDiWKrSN3M=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0024-fill-transparent-hidpi-backing-store.patch";
              hash = "sha256-YSpCSBgacD+vI73BB1vPi4EKq6lCEIv0Ht7nAq/qiOQ=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0025-update-window-geometry-on-scale-change.patch";
              hash = "sha256-m5SdnFLgXtVYjuxvSW6XohqLQGIkPKKf/ZqxTmbQ+fc=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0026-fix-backing-store-rhi-unneeded-copy.patch";
              hash = "sha256-yoB/4iqfDzdq2kA4w+gBtmP1d9RBN4Xc3TlBzXUsbBY=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0027-fix-backing-store-opengl-subimage-unneeded-copy.patch";
              hash = "sha256-6f0Y1RaRolJz43C1L38W2VxE1VPvqjniOZi7t9nHAj8=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0028-portal-proxy-resolver.patch";
              hash = "sha256-N4jdaI2zDIbzrUT1EfpPMimsRR+XqRNPNx5P96OS1+Q=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0029-fix-crash-opengl-drivers.patch";
              hash = "sha256-lXNsbR8ul7UizpMEr58wONUAvyuFkTrRonX6eGIxhs8=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0030-fix-focus-in-hidden-window.patch";
              hash = "sha256-ncUoq+/NN44tfyFTwPyw/fbbpkBAM39IWVW9PdgwEgQ=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtbase_6.7.0/0031-fix-only-emoji-line.patch";
              hash = "sha256-icwifVtnSDFl+bM/d/Q3TQvyyLAwO9p62+MTp9tXRl4=";
            })
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
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtwayland_6.7.0/0001-always-fractional-scale.patch";
              hash = "sha256-ec6LiM/K8WFUJFy4f8XviGLayXz0KXZrbe9AJCJmvPQ=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtwayland_6.7.0/0002-offload-transparency-filling-to-hidpi.patch";
              hash = "sha256-eloPgsgm+aI11it+6vsdHT609vsc/duRduhBguyZMXA=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtwayland_6.7.0/0003-popup-reposition.patch";
              hash = "sha256-i8Qu7shZzG3fyh5iWHKat1aQdNMWcplR8ne8vq/Dd1w=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtwayland_6.7.0/0004-fix-gtk4-embedding.patch";
              hash = "sha256-eIKFXwW45FL/E4nILS53RXBCkRO7+DPS3oUpB5XOOqo=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtwayland_6.7.0/0005-QWaylandShmBackingStore-Preserve-buffer-contents-bet.patch";
              hash = "sha256-JY2/Te568BBQ+90LNRg1XBoN65ip/fvn6GTKDuRGhzg=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtwayland_6.7.0/0006-avoid-needlessly-initiailizing-opengl.patch";
              hash = "sha256-/MPiEH0Ngwe/q0V7Tv2oYtrRndPUgO+ltga7tG0VstM=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtwayland_6.7.0/0007-fix-media-viewer-on-gnome.patch";
              hash = "sha256-ARyyYeTGYW2cvIWbR080fBg7hgBVkLUVauyVZuQxa/Y=";
            })
            (fetchpatch {
              url = "https://raw.githubusercontent.com/desktop-app/patches/master/qtwayland_6.7.0/0008-owning-rhi-backing-store.patch";
              hash = "sha256-MOUE8SInnqk4kpzFdz4Qo084uaGZlqAJoZMIDEjFyzk=";
            })
          ];
        })
        .override {inherit qtbase qtdeclarative;})
    ]);

  cmakeFlags = [
    "-Ddisable_autoupdate=ON"
    # 64gram
    "-DTDESKTOP_API_ID=611335"
    "-DTDESKTOP_API_HASH=d524b414d21f4d37f08684c1df41ac9c"
    # See: https://github.com/NixOS/nixpkgs/pull/130827#issuecomment-885212649
    "-DDESKTOP_APP_USE_PACKAGED_FONTS=OFF"
    "-DDESKTOP_APP_DISABLE_SCUDO=ON"
  ];
})
