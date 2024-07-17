{
  pkgs,
  pkgs-unstable,
  ...
}: {
  veyon = import ./veyon pkgs;
  _64gram = import ./_64gram pkgs-unstable;
}
