{...}: {
  virtualisation.composter.apps.ip_vanutp_dev.services.main = {
    image = "nginx:alpine";
    traefik = {};
    labels = {
      "traefik.http.routers.ip__vanutp__dev.rule" = "Host(`ip.vanutp.dev`) || Host(`ip.vtp.sh`)";
    };
    volumes = [
      "./default.conf:/etc/nginx/conf.d/default.conf:ro"
    ];
  };
  vanutp.maskman.entries = [
    {
      name = "ip.vanutp.dev";
      proxied = false;
    }
    {
      name = "ip.vtp.sh";
      proxied = false;
    }
  ];
}
