{pkgs, ...}: {
  packages.cups-kyodialog = pkgs.callPackage ./package.nix {};
}
