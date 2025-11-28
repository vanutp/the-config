{config, ...}: {
  virtualisation.composter.apps.paper_vanutp_dev = {
    services = {
      main = {
        image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
        traefik = {
          host = "paper.vanutp.dev";
          proxied = false;
        };
        env_file = config.sops.secrets.paperless.path;
        environment = {
          PAPERLESS_DBHOST = "100.64.0.6";
          PAPERLESS_DBPORT = "5432";
          PAPERLESS_DBNAME = "paperless";
          PAPERLESS_DBUSER = "paperless";
          PAPERLESS_TIKA_ENABLED = "1";
          PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://gotenberg:3000";
          PAPERLESS_TIKA_ENDPOINT = "http://tika:9998";
          PAPERLESS_REDIS = "redis://redis:6379";

          PAPERLESS_URL = "https://paper.vanutp.dev";
          PAPERLESS_TIME_ZONE = "Europe/Berlin";
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_OCR_LANGUAGES = "rus jpn";

          PAPERLESS_ENABLE_ALLAUTH = "true";
          PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
          PAPERLESS_LOGOUT_REDIRECT_URL = "https://one.vanutp.dev/application/o/paperless-ngx/end-session/";
          PAPERLESS_AUTO_LOGIN = "true";
          PAPERLESS_AUTO_CREATE = "true";
          PAPERLESS_SOCIAL_AUTO_SIGNUP = "true";
          PAPERLESS_DISABLE_REGULAR_LOGIN = "true";
          PAPERLESS_REDIRECT_LOGIN_TO_SSO = "true";
        };
        volumes = [
          "./data/data:/usr/src/paperless/data"
          "./data/media:/usr/src/paperless/media"
          "./export:/usr/src/paperless/export"
          "./consume:/usr/src/paperless/consume"
        ];
      };
      tika.image = "apache/tika:latest";
      gotenberg = {
        image = "gotenberg/gotenberg:8.25";
        command = [
          "gotenberg"
          "--chromium-disable-javascript=true"
          "--chromium-allow-list=file:///tmp/.*"
        ];
      };
      redis = {
        image = "redis:8";
        volumes = [
          "./data/redis:/data"
        ];
      };
    };
  };
}
