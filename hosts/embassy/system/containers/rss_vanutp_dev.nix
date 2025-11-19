{config, ...}: {
  virtualisation.composter.apps.rss_vanutp_dev = {
    backup.enable = true;
    services = {
      main = {
        image = "freshrss/freshrss";
        traefik = {
          host = "rss.vanutp.dev";
          proxied = false;
        };
        environment = {
          CRON_MIN = "13,43";
          TRUSTED_PROXY = "10.254.0.0/16";
          TZ = "Europe/Berlin";
          OIDC_ENABLED = "1";
          OIDC_X_FORWARDED_HEADERS = "X-Forwarded-Host X-Forwarded-Port X-Forwarded-Proto";
          OIDC_SCOPES = "openid email profile";
          OIDC_REMOTE_USER_CLAIM = "preferred_username";
        };
        env_file = config.sops.secrets.rss_vanutp_dev.path;
        volumes = [
          "./data:/var/www/FreshRSS/data"
          "./extensions:/var/www/FreshRSS/extensions"
        ];
      };
    };
  };
}
