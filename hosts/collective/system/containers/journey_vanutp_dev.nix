{config, ...}: {
  virtualisation.composter.apps.journey_vanutp_dev = let
    image = "freikin/dawarich:latest";
    env_file = config.sops.secrets.dawarich.path;
    environment = {
      RAILS_ENV = "production";
      REDIS_URL = "redis://redis:6379";
      DATABASE_HOST = "100.64.0.6";
      DATABASE_PORT = "5432";
      DATABASE_USERNAME = "dawarich";
      DATABASE_NAME = "dawarich";
      MIN_MINUTES_SPENT_IN_CITY = 60;
      APPLICATION_HOSTS = "journey.vanutp.dev";
      APPLICATION_PROTOCOL = "https";
      TIME_ZONE = "Europe/Berlin";
      # PROMETHEUS_EXPORTER_HOST means different things in main and sidekiq?
      PROMETHEUS_EXPORTER_ENABLED = "false";
      RAILS_LOG_TO_STDOUT = "true";
      SELF_HOSTED = "true";
      STORE_GEODATA = "true";

      BACKGROUND_PROCESSING_CONCURRENCY = 10;

      OIDC_ISSUER = "https://one.vanutp.dev/application/o/dawarich/";
      OIDC_REDIRECT_URI = "https://journey.vanutp.dev/users/auth/openid_connect/callback";
      OIDC_AUTO_REGISTER = "true";
      OIDC_PROVIDER_NAME = "vanutp one";
      ALLOW_EMAIL_PASSWORD_REGISTRATION = "false";
    };
    volumes = [
      "./data/public:/var/app/public"
      "./data/watched:/var/app/tmp/imports/watched"
      "./data/storage:/var/app/storage"
    ];
    depends_on.redis = {
      condition = "service_healthy";
      restart = true;
    };
  in {
    backup = {
      enable = true;
      schedule = "*-*-* 03:00:00";
    };
    services = {
      main = {
        inherit image depends_on environment env_file volumes;
        traefik = {
          host = "journey.vanutp.dev";
          proxied = false;
        };
        entrypoint = "web-entrypoint.sh";
        command = ["bin/rails" "server" "-p" "3000" "-b" "::"];
      };
      sidekiq = {
        inherit image depends_on environment env_file volumes;
        entrypoint = "sidekiq-entrypoint.sh";
        command = ["sidekiq"];
      };
      redis = {
        image = "redis:7.4-alpine";
        volumes = ["./data/redis:/data"];
        healthcheck = {
          test = ["CMD" "redis-cli" "--raw" "incr" "ping"];
          timeout = "10s";
          interval = "10s";
          retries = 5;
          start_period = "30s";
          start_interval = "5s";
        };
      };
    };
  };
  vanutp.gatus.checks.dawarich = {
    url = "https://journey.vanutp.dev/api/v1/health";
    conditions = [
      "[STATUS] == 200"
      "[BODY].status == ok"
    ];
  };
}
