{
  pkgs,
  common,
  ...
}: {
  imports = [
    common.bundles.fox
    ./shell.nix
  ];

  home.packages = with pkgs; [
    pgcli
    neovim
  ];
}
