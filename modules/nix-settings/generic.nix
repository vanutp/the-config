{
  pkgs,
  lib,
  mode,
  ...
}: {
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      # TODO: move back to system.nix after 25.11?
      use-xdg-base-directories = true;
    };
  };
  nixpkgs.config = lib.mkIf (mode != "home-bundled") {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };
}
