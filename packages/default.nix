attrs @ {
  pkgs,
  pkgs-unstable,
  ...
}: {
  veyon = import ./veyon pkgs;
  _64gram = import ./_64gram pkgs-unstable;
  vhap = (import ./vhap/pyproject.nix attrs).package;
  cups-kyodialog = pkgs.callPackage ./cups-kyodialog {};
}
