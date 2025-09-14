{...}: {
  vanutp.traefik = {
    enable = true;
    requestWildcardCertsFor = [
      "vanutp.dev"
    ];
  };
  services.nginx.commonHttpConfig = ''
    set_real_ip_from 127.0.0.1;
  '';
  virtualisation.composter.vhap-update-host = "vhap-update-memory-hole.vanutp.dev";
  vanutp.maskman.enable = true;
}
