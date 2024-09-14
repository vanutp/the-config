{
  vars,
  common,
  ...
}: {
  imports = [
    common.blocks.traefik
  ];
  vanutp.traefik = {
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
      {
        host = "vhap-update.vanutp.dev";
        target = "http://127.0.0.1:8010";
      }
    ];
    requestWildcardCertsFor = [
      vars.mainDomain
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
}
