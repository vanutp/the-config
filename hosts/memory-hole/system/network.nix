{
  setup.network = {
    interface = "enp7s0";
    ipv4 = {
      address = "65.21.206.44/26";
      gateway = "65.21.206.1";
    };
    ipv6 = {
      enable = true;
      address = "2a01:4f9:6a:14d0::1/64";
      gateway = "fe80::1";
    };
  };
}
