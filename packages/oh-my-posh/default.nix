{pkgs-unstable, ...}: {
  packages.oh-my-posh = pkgs-unstable.callPackage ./package.nix {};
}
