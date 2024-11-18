{...}: {
  virtualisation.composter.apps.zond_vanutp_dev = {
    services.umami = {
      image = "ghcr.io/umami-software/umami:postgresql-latest";
      traefik.host = "zond.vanutp.dev";
      env_file = "secrets.env";
    };
  };
}
