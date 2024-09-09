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
        host = "vhap-update.progtime.net";
        target = "http://127.0.0.1:8001";
      }
    ];
    requestWildcardCertsFor = [vars.mainDomain];
  };
}
