{config, ...}: {
  virtualisation.composter.apps.upstairs_one = {
    backup.enable = true;
    auth = ["upstairs"];
    services = {
      redis = {
        image = "redis:alpine";
        volumes = [
          "./redis:/data"
        ];
      };
      main = {
        image = "registry.gitlab.com/mes5/mes_prototype";
        volumes = [
          "./data/logs:/app/logs"
          "./data/graphs:/app/app/static/images/graphs/"
          "./data/files:/app/data/files"
        ];
        environment = {
          SERVER_NAME = "upstairs.one";
          DEBUG = "0";
        };
        env_file = config.sops.secrets.upstairs_one.path;
        traefik = {
          host = "upstairs.one";
          port = 80;
        };
      };
    };
  };
}
