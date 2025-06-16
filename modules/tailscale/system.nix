{
  lib,
  config,
  pkgs-unstable,
  ...
}: {
  services.tailscale = lib.mkMerge [
    {
      enable = true;
      package = pkgs-unstable.tailscale;
      openFirewall = true;
    }
    (lib.mkIf config.setup.isServer {useRoutingFeatures = "server";})
    (lib.mkIf config.setup.isLaptop {useRoutingFeatures = "client";})
  ];
}
