{
  mainDomain = "vanutp.dev";
  ipv4 = {
    address = "89.110.74.194/24";
    gateway = "89.110.74.1";
    gateway-on-link = false;
  };
  ipv6 = {
    address = "2a14:1e00:1:122::/64";
    gateway = "fe80::1";
    gateway-on-link = true; # TODO: а нафига
  };
}
