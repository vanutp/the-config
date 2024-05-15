{pkgs, ...}: {
  veyon = import ./veyon pkgs;
  _64gram = import ./_64gram pkgs;
  basedpyright = import ./basedpyright pkgs;
}
