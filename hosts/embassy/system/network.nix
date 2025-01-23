{
  setup.network = {
    ipv4 = {
      address = "82.146.39.189/32";
      gateway = "10.0.0.1";
      gateway-on-link = true;
    };
    ipv6 = {
      enable = true;
      address = "2a01:230:4:1ea::1874/64";
      gateway = "2a01:230:4:1ea::1";
    };
  };
}
