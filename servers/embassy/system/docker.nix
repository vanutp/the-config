{...}: {
  virtualisation.docker.daemon.settings = {
    bip = "10.254.254.1/24";
    default-address-pools = [
      {
        base = "10.254.0.0/16";
        size = 28;
      }
    ];
    ipv6 = true;
    fixed-cidr-v6 = "fd00:dead:beef:c0::/80";
    experimental = true;
  };
}
