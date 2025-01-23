{
  config,
  lib,
  ...
}: {
  # TODO: не работает если указан только (v4 без onlink)
  options.setup.network = let
    inherit (lib) mkOption types;
  in {
    enable = mkOption {
      type = types.bool;
    };
    interface = mkOption {
      type = types.str;
      default = "ens3";
    };
    ipv4 = {
      address = mkOption {
        type = types.str;
      };
      gateway = mkOption {
        type = types.str;
      };
      gateway-on-link = mkOption {
        type = types.bool;
        default = false;
      };
    };
    ipv6 = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      address = mkOption {
        type = types.str;
      };
      gateway = mkOption {
        type = types.str;
      };
      gateway-on-link = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = let
    cfg = config.setup.network;
  in {
    setup.network.enable = lib.mkDefault config.setup.isServer;
    systemd.network = lib.mkIf config.setup.network.enable {
      networks.main = lib.mkMerge [
        {
          matchConfig.Name = cfg.interface;
          address = [cfg.ipv4.address];
          dns = ["1.1.1.1"];
          routes = [
            {
              Gateway = cfg.ipv4.gateway;
              GatewayOnLink = cfg.ipv4.gateway-on-link or false;
            }
          ];
        }
        (lib.mkIf (cfg.ipv6.enable) {
          address = [cfg.ipv6.address];
          dns = ["2606:4700:4700::1111"];
          routes = [
            {
              Gateway = cfg.ipv6.gateway;
              GatewayOnLink = cfg.ipv6.gateway-on-link or false;
            }
          ];
        })
      ];
    };
  };
}
