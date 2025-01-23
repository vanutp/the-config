{
  setup.network = {
    interface = "enp34s0";
    ipv4 = {
      address = "95.217.194.10/26";
      gateway = "95.217.194.1";
    };
    ipv6 = {
      enable = true;
      address = "2a01:4f9:4a:5119::1/64";
      gateway = "fe80::1";
    };
  };
}
