{pkgs, ...}: {
  # TODO: allow only these users to connect to proxy
  # or change clientmethod to something else
  users.users.proxy-user = {
    isNormalUser = true;
    shell = "${pkgs.util-linux}/bin/nologin";
  };
  users.users.p1-proxy = {
    isNormalUser = true;
    shell = "${pkgs.util-linux}/bin/nologin";
  };
  services.dante = {
    enable = true;
    config = ''
      internal: 10.1.0.5 port = 1080
      external: 89.110.74.194
      clientmethod: none
      socksmethod: username
      client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect error
      }
      socks pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
      }
    '';
  };
}
