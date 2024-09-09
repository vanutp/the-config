{...}: {
  virtualisation.composter.apps.firefly_vanutp_dev = {
    services = {
      app = {
        image = "fireflyiii/core:latest";
        traefik.host = "firefly.vanutp.dev";
        labels = {
          "traefik.http.routers.firefly__vanutp__dev.middlewares" = "authelia@docker";
        };
        env_file = ".env";
        volumes = [
          "./data/upload:/var/www/html/storage/upload"
        ];
      };
      cron = {
        command = "sh -c \"echo \\\"0 3 * * * wget -qO- http://app:8080/api/v1/cron/$STATIC_CRON_TOKEN\\\" | crontab - && crond -f -L /dev/stdout\"";
        env_file = ".cron.env";
        image = "alpine";
      };
      importer = {
        image = "fireflyiii/data-importer:latest";
        traefik.host = "firefly-importer.vanutp.dev";
        labels = {
          "traefik.http.routers.firefly-importer__vanutp__dev.middlewares" = "authelia@docker";
        };
        depends_on = ["app"];
        env_file = ".importer.env";
      };
    };
  };
}
