{...}: {
  virtualisation.composter.apps.vanutp_dev = {
    services = {
      backend = {
        image = "registry.vanutp.dev/vanutpdev/backend";
        traefik = {};
        labels = {
          "traefik.http.routers.vanutp_dev_backend.rule" = "Host(`vanutp.dev`) && PathPrefix(`/api`)";
        };
        env_file = "secrets.env";
      };
      frontend = {
        image = "nginx:alpine";
        traefik.host = "vanutp.dev";
        volumes = [
          "./content:/app:ro"
          "./default.conf:/etc/nginx/conf.d/default.conf:ro"
        ];
      };
    };
  };
}
