{
  common,
  pkgs,
  ...
}: {
  imports = [
    common.bundles.root
  ];
  home.packages = with pkgs; [
    ventoy-full
  ];
}
