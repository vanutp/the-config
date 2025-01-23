{...}: {
  virtualisation.composter.apps.ilkras_ru.services.main = {
    image = "registry.vanutp.dev/vanutp/nginx-spa";
    traefik = {};
    labels = {
      "traefik.http.routers.ilkras__ru.rule" = "HostRegexp(`ilkras.ru`, `{subdomain:[a-z]+}.ilkras.ru`) && !Host(`pb.ilkras.ru`) && !Host(`casino.ilkras.ru`)";
    };
    volumes = [
      "./default.conf:/etc/nginx/conf.d/default.conf:ro"
      "./content:/content:ro"
    ];
  };
}
