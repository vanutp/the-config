{...}: {
  sops.secrets."services/traefik-cloudflare-config" = {};
  vanutp.traefik = {
    enable = true;
    requestWildcardCertsFor = [
      "foxlab.dev"
      "vanutp.dev"
      "vtp.sh"
    ];
  };
  services.nginx.commonHttpConfig = ''
    set_real_ip_from 127.0.0.1;
  '';
}
