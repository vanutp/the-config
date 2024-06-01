{vars, ...}: {
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
    ];
    tlsDomains = [vars.mainDomain "upstairs.one" "tmat.me" "ilkras.ru" "foxlab.dev"];
  };
}
