{
  pkgs,
  common,
  ...
}: {
  imports = [
    common.bundles.all-users
    common.bundles.fox
    ./shell.nix
  ];

  home.packages = with pkgs; [
    pgcli
    neovim
  ];
}
