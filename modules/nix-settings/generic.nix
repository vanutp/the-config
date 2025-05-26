{
  pkgs,
  lib,
  mode,
  ...
}: {
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };
  nixpkgs.config = lib.mkIf (mode != "home-bundled") {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };
}
