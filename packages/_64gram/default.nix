{pkgs, ...}: {
  packages._64gram = import ./package.nix pkgs;
}
