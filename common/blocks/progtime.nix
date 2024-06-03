{
  domain,
  backendCfg,
  invokerCfg,
  secretsFile,
}: {
  config,
  common,
  pkgs,
  ...
}: let
  blockName = builtins.replaceStrings ["."] ["_"] domain;
  dataDir = "${common.constants.servicesDataRoot}/${blockName}";
  login = import ../utils/vanutp-registry.nix config;
in {
  virtualisation.composter.services.${blockName}.containers = {
    redis = {
      image = "docker.io/redis:alpine";
      volumes = [
        "${dataDir}/redis:/data"
      ];
    };

    invoker = {
      inherit login;
      image = "registry.vanutp.dev/progtime/repo/invoker";
      extraOptions = [
        "--privileged"
      ];
      volumes = [
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        "/sys/fs/cgroup:/sys/fs/cgroup"
      ];
      environment =
        {
          HOST = "0.0.0.0";
          PORT = "8000";
          WS_ADDRESS = "ws://ws:8000";
        }
        // invokerCfg;
      environmentFiles = [secretsFile];
    };

    ws = {
      inherit login;
      image = "registry.vanutp.dev/progtime/repo/ws";
      environment = {
        HOST = "0.0.0.0";
        PORT = "8000";
        FORWARDED_ALLOW_IPS = "*";
        API_ADDRESS = "http://api:8000";
      };
      environmentFiles = [secretsFile];
    };

    api = {
      inherit login;
      image = "registry.vanutp.dev/progtime/repo/api";
      dependsOn = [
        "redis"
        "invoker"
      ];
      volumes = [
        "${dataDir}/app:/app/data"
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
      environmentFiles = [secretsFile];
    };

    nginx = {
      inherit login;
      image = "registry.vanutp.dev/progtime/repo/nginx";
      dependsOn = [
        "api"
        "ws"
      ];
      traefik.host = domain;
    };
  };
  system.activationScripts."${blockName}-create-data-dir".text = ''
    mkdir -p ${dataDir} ${dataDir}/redis ${dataDir}/app
  '';
}
