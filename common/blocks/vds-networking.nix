{vars, ...}: {
  # TODO: не работает если указан только (v4 без onlink)
  systemd.network = {
    networks.main = {
      matchConfig.Name = vars.networkInterface or "ens3";
      address =
        [vars.ipv4.address]
        ++ (
          if vars ? ipv6
          then [vars.ipv6.address]
          else []
        );
      dns =
        ["1.1.1.1"]
        ++ (
          if vars ? ipv6
          then ["2606:4700:4700::1111"]
          else []
        );
      routes =
        [
          {
            routeConfig = {
              Gateway = vars.ipv4.gateway;
              GatewayOnLink = vars.ipv4.gateway-on-link or false;
            };
          }
        ]
        ++ (
          if vars ? ipv6
          then [
            {
              routeConfig = {
                Gateway = vars.ipv6.gateway;
                GatewayOnLink = vars.ipv6.gateway-on-link or false;
              };
            }
          ]
          else []
        );
    };
  };
}
