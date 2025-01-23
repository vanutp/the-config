{pkgs, ...}: {
  packages.veyon = import ./package.nix pkgs;
}
