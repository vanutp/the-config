{config, ...}: {
  virtualisation.composter.apps.rkp_vanutp_dev = {
    backup.enable = true;
    services = {
      main = {
        image = "remnawave/backend:2";
        hostname = "remnawave";
        ulimits.nofile = {
          soft = 1048576;
          hard = 1048576;
        };
        environment = {
          API_INSTANCES = 1;
          REDIS_HOST = "redis";
          REDIS_PORT = "6379";
          FRONT_END_DOMAIN = "rkp.vanutp.dev";
          SUB_PUBLIC_DOMAIN = "sub.rkp.vanutp.dev/meow";
          SWAGGER_PATH = "/docs";
          SCALAR_PATH = "/scalar";
          IS_DOCS_ENABLED = "true";
          IS_TELEGRAM_NOTIFICATIONS_ENABLED = "true";
        };
        env_file = config.sops.secrets."remnawave/panel".path;
        traefik = {
          host = "rkp.vanutp.dev";
          port = 3000;
          middlewares = ["authentik@docker"];
          proxied = false;
        };
        depends_on.redis.condition = "service_healthy";
      };
      subscription = {
        image = "remnawave/subscription-page:latest";
        environment = {
          APP_PORT = 3010;
          REMNAWAVE_PANEL_URL = "http://main:3000";
          CUSTOM_SUB_PREFIX = "meow";
        };
        env_file = config.sops.secrets."remnawave/subscription".path;
        traefik = {
          host = "sub.rkp.vanutp.dev";
          certresolver = "http";
          port = 3010;
          proxied = false;
        };
      };
      redis = {
        image = "valkey/valkey:8.1-alpine";
        command = ''
          valkey-server
          --save ""
          --appendonly no
          --maxmemory-policy noeviction
          --loglevel warning
        '';
        healthcheck = {
          test = ["CMD" "valkey-cli" "ping"];
          interval = "3s";
          timeout = "3s";
          retries = 3;
        };
      };
    };
  };
}
