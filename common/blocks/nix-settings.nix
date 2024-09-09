{
  pkgs,
  lib,
  ...
}: {
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      use-xdg-base-directories = true;
      experimental-features = ["nix-command" "flakes" "repl-flake"];
    };
  };
}
