{...}: {
  sops.secrets."services/traefik-cloudflare-config" = {};
  vanutp.traefik = {
    enable = true;
    requestWildcardCertsFor = [
      "foxlab.dev"
      "vanutp.dev"
      "vtp.sh"
      "speech-cabinet.com"
    ];
  };
  services.nginx.commonHttpConfig = ''
    set_real_ip_from 127.0.0.1;
  '';
  virtualisation.composter.vhap-update-host = "vhap-update-collective.vanutp.dev";
}
