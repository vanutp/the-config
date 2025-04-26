{...}: {
  virtualisation.composter.apps.rss_vanutp_dev = {
    backup.enable = true;
    services = {
      main = {
        image = "freshrss/freshrss";
        traefik.host = "rss.vanutp.dev";
        environment = {
          CRON_MIN = "13,43";
          TRUSTED_PROXY = "172.16.0.1/12 192.168.0.1/16";
          TZ = "Europe/Berlin";
        };
        volumes = [
          "./data:/var/www/FreshRSS/data"
          "./extensions:/var/www/FreshRSS/extensions"
        ];
      };
    };
  };
}
