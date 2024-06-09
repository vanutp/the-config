{vars, ...}: {
  # TODO: use nixos networkd module
  environment.etc."systemd/network/main.network".text = let
    v4gateway = "Gateway=${vars.ipv4.gateway}";
  in ''
    [Match]
    Name=ens3

    [Network]
    Address=${vars.ipv4.address}
    DNS=1.1.1.1
    ${
      if vars ? ipv6
      then v4gateway
      else ""
    }

    ${
      if vars ? ipv6
      then ''
        Address=${vars.ipv6.address}
        DNS=2606:4700:4700::1111
        Gateway=${vars.ipv6.gateway}
      ''
      else ""
    }

    [Route]
    ${
      if !(vars ? ipv6)
      then v4gateway
      else ""
    }
    GatewayOnLink=${
      if vars.gateway-on-link
      then "yes"
      else "no"
    }
  '';
}
