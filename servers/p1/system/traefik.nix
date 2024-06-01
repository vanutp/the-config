{vars, ...}: {
  vanutp.traefik = {
    proxies = [
      {
        host = "vhap-update.progtime.net";
        target = "http://127.0.0.1:8001";
      }
    ];
    tlsDomains = [vars.mainDomain];
  };
}
