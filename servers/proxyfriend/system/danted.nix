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
      internal: 10.3.0.1 port = 1080
      external: 89.110.74.194
      external: 2a14:1e00:1:122::
      clientmethod: none
      socksmethod: username
      client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect error
      }
      socks pass {
        from: 0/0 to: 0/0
      }
    '';
  };
  systemd.services.dante.requires = ["wg-quick-wg0.service" "wg-quick-wg1.service"];
  networking.firewall.allowedTCPPorts = [1080];
}
