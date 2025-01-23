{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.setup.isServer {
  home.packages = with pkgs; [
    python3
  ];
}
