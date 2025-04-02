{
  config,
  lib,
  ...
}: let
  mkProgtime = {
    domain,
    backendCfg,
    invokerCfg,
    secretsFile,
  }: {
    ${builtins.replaceStrings ["."] ["_"] domain} = {
      auth = ["foxlab-pt"];
      services = {
        redis = {
          image = "redis:alpine";
          volumes = ["./data/redis:/data"];
        };

        invoker = {
          image = "registry.vanutp.dev/progtime/repo/invoker";
          privileged = true;
          cgroup = "host";
          volumes = [
            "./logs/invoker:/app/logs/invoker"
            "/var/run/docker.sock:/var/run/docker.sock:ro"
            "/sys/fs/cgroup:/sys/fs/cgroup"
          ];
          environment =
            {
              HOST = "0.0.0.0";
              PORT = "8000";
              WS_ADDRESS = "ws://ws:8000";
            }
            // invokerCfg;
          env_file = secretsFile;
        };

        ws = {
          image = "registry.vanutp.dev/progtime/repo/ws";
          volumes = [
            "./logs/ws:/app/logs/ws"
          ];
          environment = {
            HOST = "0.0.0.0";
            PORT = "8000";
            FORWARDED_ALLOW_IPS = "*";
            API_ADDRESS = "http://api:8000";
          };
          env_file = secretsFile;
        };

        api = {
          image = "registry.vanutp.dev/progtime/repo/api";
          depends_on = [
            "redis"
            "invoker"
          ];
          volumes = [
            "./logs/async:/app/logs/async"
            "./data/app:/app/data"
          ];
          environment =
            {
              SERVER_NAME = domain;
              BASE_URL = "https://${domain}";
              HOST = "0.0.0.0";
              PORT = "8000";
              REDIS_URL = "redis://redis:6379/0";
              WS_ADDRESS = "http://ws:8000";
              INVOKER_ADDRESS = "ws://invoker:8000";
              FORWARDED_ALLOW_IPS = "*";
            }
            // backendCfg;
          env_file = secretsFile;
        };

        nginx = {
          image = "registry.vanutp.dev/progtime/repo/nginx";
          depends_on = [
            "api"
            "ws"
          ];
          traefik.host = domain;
        };
      };
    };
  };
in {
  virtualisation.composter.apps = lib.mkMerge [
    (mkProgtime {
      domain = "my.progtime.net";
      secretsFile = config.sops.secrets."services/my_progtime_net".path;
      backendCfg = {
        INSTANCE_TITLE = "Прогтайм";
        INSTANCE_SUBTITLE = "";
        WORKERS = "2";
      };
      invokerCfg.ENABLE_INTERACTIVE = "True";
    })
    (mkProgtime {
      domain = "demo.progtime.net";
      secretsFile = config.sops.secrets."services/demo_progtime_net".path;
      backendCfg = {
        INSTANCE_TITLE = "Прогтайм";
        INSTANCE_SUBTITLE = "";
        WORKERS = "1";
        LOGIN_TEXT = "<h5 style=\"margin-bottom: 2rem\">Демо инстанс Progtime</h5><p>Логин: admin0<br/>Пароль: admin0</p>";
      };
      invokerCfg.ENABLE_INTERACTIVE = "True";
    })
  ];
}
