{
  pkgs,
  common,
  ...
}: {
  imports = [
    common.bundles.all-users
    common.blocks.shell
  ];

  home.packages = with pkgs; [
    micro
    nano
    neovim
  ];

  home.username = "gravity_m";
  home.homeDirectory = "/home/gravity_m";
}
