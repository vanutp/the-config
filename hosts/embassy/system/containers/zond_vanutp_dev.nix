{config, ...}: {
  virtualisation.composter.apps.zond_vanutp_dev = {
    services.umami = {
      image = "ghcr.io/umami-software/umami:postgresql-latest";
      traefik = {
        host = "zond.vanutp.dev";
        proxied = false;
      };
      env_file = config.sops.secrets.zond_vanutp_dev.path;
    };
  };
}
