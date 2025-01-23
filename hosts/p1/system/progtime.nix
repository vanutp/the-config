{
  domain,
  backendCfg,
  invokerCfg,
  secretsFile,
  auth,
}: {
  config,
  pkgs,
  ...
}: let
  blockName = builtins.replaceStrings ["."] ["_"] domain;
in {
  virtualisation.composter.apps.${blockName} = {
    inherit auth;
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
}
