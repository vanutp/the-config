{
  pkgs,
  lib,
  ...
}: {
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };
  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };
}
