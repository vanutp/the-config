{vars, ...}: {
  # TODO: use nixos networkd module
  environment.etc."systemd/network/main.network".text = ''
    [Match]
    Name=ens3

    [Network]
    Address=${vars.ipv4.address}
    DNS=1.1.1.1
    Gateway=${vars.ipv4.gateway}

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
    GatewayOnLink=${
      if vars.gateway-on-link
      then "yes"
      else "no"
    }
  '';
}
