{...}: {
  vanutp.traefik = {
    enable = true;
    proxies = [
      {
        host = "tardis-7000.vanutp.dev";
        target = "http://10.1.1.2:7000";
      }
    ];
    requestWildcardCertsFor = [
      "vanutp.dev"
      "upstairs.one"
      "tmat.me"
      "foxlab.dev"
      "vtp.sh"
    ];
    extraDynamicConfig = {
      tls.certificates = [
        {
          certFile = "/data/tls/fox.crt";
          keyFile = "/data/tls/fox.key";
        }
      ];
    };
  };
  virtualisation.composter.vhap-update-host = "vhap-update.vanutp.dev";
  vanutp.maskman.enable = true;
}
