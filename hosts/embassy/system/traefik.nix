{...}: {
  vanutp.traefik = {
    enable = true;
    proxies = [
      {
        host = "cloud.vanutp.dev";
        target = "http://10.1.0.2:8015";
      }
      {
        host = "tardis-7000.vanutp.dev";
        target = "http://10.1.1.2:7000";
      }
      {
        host = "pg.vanutp.dev";
        target = "http://10.1.0.4:5001";
      }
    ];
    requestWildcardCertsFor = [
      "vanutp.dev"
      "upstairs.one"
      "tmat.me"
      "ilkras.ru"
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
