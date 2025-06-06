{...}: {
  virtualisation.composter.apps.frontend-proxy = {
    backup.enable = true;
    services.main = {
      image = "registry.vanutp.dev/vanutp/frontend-proxy:latest";
      traefik = {
        host = "proxy.vanutp.dev";
        port = 1874;
      };
      volumes = [
        "./config.yml:/app/config.yml:ro"
      ];
    };
  };
}
