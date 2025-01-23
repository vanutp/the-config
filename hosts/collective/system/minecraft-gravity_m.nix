{
  config,
  pkgs,
  ...
}: {
  users.users.gravity_m = {
    isNormalUser = true;
    extraGroups = ["docker"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      config.setup.pubkeys.main
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCugrARVJwD2kmpLFfJmkHHJzvTVBCH7xslbXCC4LvyuMFDH6Qv9wN0etMrLtOskchgUiOR4uXgdTdX2pQjhyXgD4E5MFcWEnOnh4XX1Jeo+TXsM866KM64x2rXRj8gwGUZCZJMCoyTb1lFtVSw74ocOyZE5vYG+OlRafHOazM3hD9lzlElCV/Lkr/TbUnR1SUo1W+PU1atTBG/d187L7DUCHwUmdmUrZBSV1bKzWzC2VcluSBYJGujLXlnUVfEpL4rq4WnrU+pCALCZ2xdZpZ6RWIruPLooPjIW0HdgxiNzlewSTdFK812Qe69B59ANqRxyCKkcATm3DSGFIuM+2/K+ziIIcFnSxllDtob89yHfuG4anFo59blOTwxNLaVYMuYwkkVTAWnt0/rC1u0fyP///5PffN0DwE19a0dH1aNW4c/1NDMa7Wp1Jj87U/54oM/hnGMBW+ANmjE4wsbQhVJulPiINzMdGKal7e1MZl3ohuk+hqwTrJDne8TP27IYu8= dvaer@gravity"
    ];
  };

  networking.firewall.allowedTCPPorts = [25555];
  networking.firewall.allowedUDPPorts = [24455];
  services.nginx = {
    enable = true;
    virtualHosts."gr.vtp.sh" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8101";
      };
    };
  };
}
