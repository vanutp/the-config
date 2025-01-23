{...}: {
  vanutp.traefik = {
    enable = true;
    proxies = [
      {
        host = "vhap-update.progtime.net";
        target = "http://127.0.0.1:8001";
      }
    ];
    requestWildcardCertsFor = ["progtime.net"];
  };
}
